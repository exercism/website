#!/usr/bin/env node
/*
 * Two rules, enforced together, because the first is unsound without the second.
 *
 * Rule A: every translation key resolves against the namespace its own file
 * declares in useAppTranslation('<namespace>'), or against the namespace the
 * call names explicitly ('ns:key' or { ns: '...' }).
 *
 * Rule B: a translation function is obtained in the file that uses it. It is
 * never a parameter, never an argument, and never returned. Without rule B a
 * file's declared namespace says nothing about the namespace a given `t` was
 * built from, and rule A can only guess.
 *
 * A key i18next resolves at runtime but this script cannot resolve statically
 * is reported, never passed over. A key built from a template literal is
 * checked by its static prefix, and one built from a conditional is checked on
 * both branches. What is left is genuinely opaque, and allowlist.json holds
 * those exceptions, one per file and rule, each with a reason. An entry that
 * stops suppressing anything is itself reported, so the list cannot rot.
 */

const fs = require('fs')
const path = require('path')
const { parse } = require('@babel/parser')

const ROOT = path.resolve(__dirname, '../../../..')
const JS_ROOT = path.join(ROOT, 'app/javascript')
const EN_DIR = path.join(JS_ROOT, 'i18n/en')
const ALLOWLIST = require('./allowlist.json')

const SKIP_DIRS = new Set(['node_modules'])
// The interpreter ships its own i18next instance and its own JSON catalogs, so
// its keys are not app namespaces. The extract-* tools build prompts that
// contain example t() calls as string data.
const SKIP_PATHS = [
  'app/javascript/interpreter',
  'app/javascript/i18n/en',
  'app/javascript/i18n/extract-jsx-copy',
  'app/javascript/i18n/extract-haml-copy',
]

const PLURAL_SUFFIXES = ['_zero', '_one', '_two', '_few', '_many', '_other']
const HOOK_NAMES = new Set(['useAppTranslation', 'useTranslation'])
const I18N_OBJECTS = new Set(['i18n', 'i18next'])
const TRANSLATOR_NAMES = new Set(['t'])

function parseFile(file) {
  return parse(fs.readFileSync(file, 'utf8'), {
    sourceType: 'module',
    plugins: ['typescript', 'jsx', 'classProperties', 'decorators-legacy'],
    errorRecovery: true,
  })
}

function walkDir(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      if (SKIP_DIRS.has(entry.name)) continue
      walkDir(full, out)
    } else if (/\.(ts|tsx)$/.test(entry.name)) {
      out.push(full)
    }
  }
  return out
}

function staticKey(node) {
  if (!node) return null
  if (node.type === 'StringLiteral') return node.value
  if (node.type === 'TemplateLiteral' && node.expressions.length === 0) {
    return node.quasis.map((q) => q.value.cooked).join('')
  }
  return null
}

function flattenCatalog(objectNode, prefix, into) {
  for (const prop of objectNode.properties) {
    if (prop.type !== 'ObjectProperty') continue
    const name =
      prop.key.type === 'StringLiteral' ? prop.key.value : prop.key.name
    if (name === undefined) continue
    const full = prefix ? `${prefix}.${name}` : name
    if (prop.value.type === 'ObjectExpression') {
      flattenCatalog(prop.value, full, into)
    } else {
      into.add(full)
    }
  }
}

function loadCatalogs() {
  const indexAst = parseFile(path.join(EN_DIR, 'index.ts'))
  const imports = new Map()
  const namespaces = new Map()

  for (const node of indexAst.program.body) {
    if (node.type === 'ImportDeclaration') {
      const spec = node.specifiers.find(
        (s) => s.type === 'ImportDefaultSpecifier'
      )
      if (spec) imports.set(spec.local.name, node.source.value)
    }
    if (
      node.type === 'ExportDefaultDeclaration' &&
      node.declaration.type === 'ObjectExpression'
    ) {
      for (const prop of node.declaration.properties) {
        if (prop.type !== 'ObjectProperty') continue
        const ns =
          prop.key.type === 'StringLiteral' ? prop.key.value : prop.key.name
        const source = imports.get(prop.value.name)
        if (!source) continue
        const file = path.join(EN_DIR, `${source.replace(/^\.\//, '')}.ts`)
        const keys = new Set()
        const ast = parseFile(file)
        for (const stmt of ast.program.body) {
          if (
            stmt.type === 'ExportDefaultDeclaration' &&
            stmt.declaration.type === 'ObjectExpression'
          ) {
            flattenCatalog(stmt.declaration, '', keys)
          }
        }
        namespaces.set(ns, keys)
      }
    }
  }
  return namespaces
}

function resolveKey(node, resolveString) {
  if (!node) return null
  const literal = resolveString(node)
  if (literal !== null) return { exact: [literal] }

  if (node.type === 'ConditionalExpression') {
    const left = resolveKey(node.consequent, resolveString)
    const right = resolveKey(node.alternate, resolveString)
    if (left && right && left.exact && right.exact) {
      return { exact: [...left.exact, ...right.exact] }
    }
    return null
  }

  if (node.type === 'TemplateLiteral') {
    const prefix = node.quasis[0].value.cooked
    if (prefix && prefix.includes('.')) return { prefix }
    return null
  }

  return null
}

function hasKey(keys, key) {
  if (keys.has(key)) return true
  return PLURAL_SUFFIXES.some((suffix) => keys.has(key + suffix))
}

function optionsNamespace(node) {
  if (!node || node.type !== 'ObjectExpression') return undefined
  for (const prop of node.properties) {
    if (prop.type !== 'ObjectProperty') continue
    const name =
      prop.key.type === 'StringLiteral' ? prop.key.value : prop.key.name
    if (name !== 'ns') continue
    const value = staticKey(prop.value)
    return value === null ? { dynamic: true } : { ns: value }
  }
  return undefined
}

function attrKey(attr, resolveString) {
  if (!attr || !attr.value) return null
  if (attr.value.type === 'StringLiteral') return { exact: [attr.value.value] }
  if (attr.value.type === 'JSXExpressionContainer') {
    return resolveKey(attr.value.expression, resolveString)
  }
  return null
}

function jsxAttr(node, name) {
  return node.attributes.find(
    (a) => a.type === 'JSXAttribute' && a.name.name === name
  )
}

function attrString(attr, resolve) {
  if (!attr || !attr.value) return null
  if (attr.value.type === 'StringLiteral') return attr.value.value
  if (attr.value.type === 'JSXExpressionContainer')
    return resolve(attr.value.expression)
  return null
}

function eachChild(node, fn) {
  for (const key of Object.keys(node)) {
    if (
      key === 'loc' ||
      key === 'leadingComments' ||
      key === 'trailingComments'
    )
      continue
    const child = node[key]
    if (Array.isArray(child))
      child.forEach((c) => c && typeof c.type === 'string' && fn(c))
    else if (child && typeof child.type === 'string') fn(child)
  }
}

function isFunctionNode(node) {
  return (
    node.type === 'FunctionDeclaration' ||
    node.type === 'FunctionExpression' ||
    node.type === 'ArrowFunctionExpression' ||
    node.type === 'ObjectMethod' ||
    node.type === 'ClassMethod'
  )
}

function collectStringConstants(ast) {
  const seen = new Map()
  const walk = (node) => {
    if (node.type === 'VariableDeclarator' && node.id.type === 'Identifier') {
      const value = staticKey(node.init)
      if (value !== null) {
        seen.set(node.id.name, seen.has(node.id.name) ? null : value)
      } else {
        seen.set(node.id.name, null)
      }
    }
    eachChild(node, walk)
  }
  walk(ast.program)
  return seen
}

function isTranslatorIdentifier(node) {
  return node && node.type === 'Identifier' && TRANSLATOR_NAMES.has(node.name)
}

function callsTranslator(node) {
  let found = false
  const walk = (current) => {
    if (found) return
    if (
      current.type === 'CallExpression' &&
      isTranslatorIdentifier(current.callee) &&
      staticKey(current.arguments[0]) !== null
    ) {
      found = true
      return
    }
    eachChild(current, walk)
  }
  walk(node)
  return found
}

function shadowsTranslator(node) {
  for (const param of node.params) {
    const target = param.type === 'AssignmentPattern' ? param.left : param
    if (isTranslatorIdentifier(target)) return true
    if (target.type === 'ObjectPattern') {
      if (
        target.properties.some(
          (p) =>
            p.type === 'ObjectProperty' &&
            p.key.type === 'Identifier' &&
            TRANSLATOR_NAMES.has(p.key.name)
        )
      ) {
        return true
      }
    }
  }
  return false
}

function translatorParams(node) {
  const found = []
  for (const param of node.params) {
    const target = param.type === 'AssignmentPattern' ? param.left : param
    if (isTranslatorIdentifier(target)) {
      found.push({
        line: target.loc.start.line,
        detail: 'declared as a function parameter',
      })
    }
    if (target.type === 'ObjectPattern') {
      for (const prop of target.properties) {
        if (
          prop.type === 'ObjectProperty' &&
          prop.key.type === 'Identifier' &&
          TRANSLATOR_NAMES.has(prop.key.name)
        ) {
          found.push({
            line: prop.loc.start.line,
            detail: 'destructured out of a function parameter',
          })
        }
      }
    }
  }
  return found
}

function collectCalls(ast) {
  const declared = new Set()
  const keyCalls = []
  const crossings = []
  const constants = collectStringConstants(ast)
  let bindsTranslator = false

  const resolveString = (node) => {
    const literal = staticKey(node)
    if (literal !== null) return literal
    if (node && node.type === 'Identifier' && constants.get(node.name)) {
      return constants.get(node.name)
    }
    return null
  }

  const visit = (node, parent, shadowed) => {
    if (isFunctionNode(node) && shadowsTranslator(node)) shadowed = true

    if (node.type === 'CallExpression') {
      const callee = node.callee

      if (callee.type === 'Identifier' && HOOK_NAMES.has(callee.name)) {
        const ns = resolveString(node.arguments[0])
        declared.add(ns)
        if (
          parent &&
          parent.type === 'VariableDeclarator' &&
          parent.id.type === 'ObjectPattern' &&
          parent.id.properties.some(
            (p) =>
              p.type === 'ObjectProperty' &&
              p.key.type === 'Identifier' &&
              TRANSLATOR_NAMES.has(p.key.name)
          )
        ) {
          bindsTranslator = true
        }
      }

      const isBareT = isTranslatorIdentifier(callee)
      const isI18nT =
        callee.type === 'MemberExpression' &&
        !callee.computed &&
        callee.property.type === 'Identifier' &&
        callee.property.name === 't' &&
        callee.object.type === 'Identifier' &&
        I18N_OBJECTS.has(callee.object.name)

      if (
        (isBareT && !shadowed && (bindsTranslator || callsTranslator(node))) ||
        isI18nT
      ) {
        keyCalls.push({
          line: node.loc.start.line,
          shape: isBareT
            ? 't(...)'
            : `${callee.object ? callee.object.name : 'i18n'}.t(...)`,
          key: resolveKey(node.arguments[0], resolveString),
          options:
            optionsNamespace(node.arguments[1]) ||
            optionsNamespace(node.arguments[2]),
        })
      }

      for (const arg of node.arguments) {
        if (isTranslatorIdentifier(arg) && bindsTranslator && !shadowed) {
          crossings.push({
            line: arg.loc.start.line,
            detail: `passed as an argument to ${describeCallee(callee)}`,
          })
        }
      }
    }

    if (node.type === 'JSXOpeningElement') {
      const name = node.name.type === 'JSXIdentifier' ? node.name.name : null
      if (name === 'Trans') {
        const keyAttr = jsxAttr(node, 'i18nKey')
        const nsAttr = jsxAttr(node, 'ns')
        const ns = nsAttr ? attrString(nsAttr, resolveString) : undefined
        if (keyAttr) {
          keyCalls.push({
            line: node.loc.start.line,
            shape: '<Trans i18nKey>',
            key: attrKey(keyAttr, resolveString),
            options: nsAttr
              ? typeof ns === 'string'
                ? { ns }
                : { dynamic: true }
              : undefined,
          })
        }
      } else {
        const attr = jsxAttr(node, 't')
        if (
          attr &&
          bindsTranslator &&
          !shadowed &&
          attr.value &&
          attr.value.type === 'JSXExpressionContainer' &&
          isTranslatorIdentifier(attr.value.expression)
        ) {
          crossings.push({
            line: attr.loc.start.line,
            detail: `passed as the \`t\` prop of <${name}>`,
          })
        }
      }
    }

    if (isFunctionNode(node)) {
      const params = translatorParams(node)
      if (params.length > 0 && node.body && callsTranslator(node.body)) {
        crossings.push(...params)
      }
    }

    if (
      node.type === 'ReturnStatement' &&
      bindsTranslator &&
      !shadowed &&
      isTranslatorIdentifier(node.argument)
    ) {
      crossings.push({
        line: node.loc.start.line,
        detail: 'returned from a function',
      })
    }

    if (node.type === 'ObjectExpression' && bindsTranslator && !shadowed) {
      for (const prop of node.properties) {
        if (
          prop.type === 'ObjectProperty' &&
          isTranslatorIdentifier(prop.value)
        ) {
          crossings.push({
            line: prop.loc.start.line,
            detail: 'placed in an object literal, which lets it leave the file',
          })
        }
      }
    }

    if (node.type === 'ExportNamedDeclaration' && node.specifiers) {
      for (const spec of node.specifiers) {
        if (spec.local && TRANSLATOR_NAMES.has(spec.local.name)) {
          crossings.push({
            line: spec.loc.start.line,
            detail: 'exported from the file',
          })
        }
      }
    }

    eachChild(node, (child) => visit(child, node, shadowed))
  }

  visit(ast.program, null, false)
  return { declared, keyCalls, crossings }
}

function describeCallee(callee) {
  if (callee.type === 'Identifier') return `${callee.name}()`
  if (callee.type === 'MemberExpression' && !callee.computed)
    return `.${callee.property.name}()`
  return 'a call'
}

const usedAllowlist = new Set()

function allowed(relative, rule) {
  const entry = ALLOWLIST.find((e) => e.file === relative && e.rule === rule)
  if (!entry) return false
  usedAllowlist.add(entry)
  return true
}

function main() {
  const namespaces = loadCatalogs()
  const files = walkDir(JS_ROOT).filter((file) => {
    const relative = path.relative(ROOT, file)
    return !SKIP_PATHS.some((skip) => relative.startsWith(skip))
  })

  const failures = []

  for (const file of files) {
    const relative = path.relative(ROOT, file)
    let parsed
    try {
      parsed = collectCalls(parseFile(file))
    } catch (e) {
      failures.push({
        file: relative,
        line: 0,
        rule: 'parse',
        message: `could not be parsed: ${e.message}`,
      })
      continue
    }

    const { declared, keyCalls, crossings } = parsed

    for (const crossing of crossings) {
      if (allowed(relative, 'B')) continue
      failures.push({
        file: relative,
        line: crossing.line,
        rule: 'B',
        message: `a translation function is ${crossing.detail}. Call useAppTranslation() in this file instead.`,
      })
    }

    const declaredList = [...declared]
    const defaultNs = declaredList.length === 1 ? declaredList[0] : undefined

    for (const call of keyCalls) {
      if (allowed(relative, 'A')) continue

      if (call.options && call.options.dynamic) {
        failures.push({
          file: relative,
          line: call.line,
          rule: 'A',
          message: `${call.shape} names its namespace dynamically, so the key cannot be checked.`,
        })
        continue
      }

      if (call.key === null) {
        failures.push({
          file: relative,
          line: call.line,
          rule: 'A',
          message: `${call.shape} builds its key dynamically with nothing static to check against. Use a literal key, or add an allowlist entry with a reason.`,
        })
        continue
      }

      const resolve = (raw) => {
        let ns = call.options ? call.options.ns : undefined
        let key = raw
        if (ns === undefined && key.includes(':')) {
          const idx = key.indexOf(':')
          ns = key.slice(0, idx)
          key = key.slice(idx + 1)
        }
        return { ns: ns === undefined ? defaultNs : ns, key }
      }

      const report = (message) =>
        failures.push({ file: relative, line: call.line, rule: 'A', message })

      const candidates = call.key.exact || [call.key.prefix]
      for (const raw of candidates) {
        const { ns, key } = resolve(raw)

        if (ns === undefined) {
          report(
            declaredList.length === 0
              ? `${call.shape} key '${key}' has no namespace. This file never calls useAppTranslation('<namespace>').`
              : `${call.shape} key '${key}' is ambiguous. This file declares ${
                  declaredList.length
                } namespaces: ${declaredList.join(', ')}.`
          )
          continue
        }

        const keys = namespaces.get(ns)
        if (!keys) {
          report(
            `namespace '${ns}' has no English catalog in app/javascript/i18n/en.`
          )
          continue
        }

        if (call.key.prefix) {
          const matched = [...keys].some((existing) => existing.startsWith(key))
          if (!matched) {
            report(
              `${call.shape} builds a key starting '${key}', and namespace '${ns}' has no key with that prefix.`
            )
          }
          continue
        }

        if (!hasKey(keys, key)) {
          report(`key '${key}' is not in namespace '${ns}'.`)
        }
      }
    }
  }

  for (const entry of ALLOWLIST) {
    if (!entry.reason) {
      failures.push({
        file: 'app/javascript/i18n/check-namespaces/allowlist.json',
        line: 0,
        rule: 'allowlist',
        message: `the entry for ${entry.file} (rule ${entry.rule}) has no reason.`,
      })
    }
    if (!usedAllowlist.has(entry)) {
      failures.push({
        file: 'app/javascript/i18n/check-namespaces/allowlist.json',
        line: 0,
        rule: 'allowlist',
        message: `the entry for ${entry.file} (rule ${entry.rule}) no longer suppresses anything. Delete it.`,
      })
    }
  }

  failures.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line)

  for (const failure of failures) {
    console.error(
      `${failure.file}:${failure.line}  [rule ${failure.rule}]  ${failure.message}`
    )
  }

  const scanned = `${files.length} files, ${namespaces.size} namespaces`
  if (failures.length > 0) {
    console.error(
      `\ni18n namespace check failed: ${failures.length} problem(s) across ${scanned}.`
    )
    process.exit(1)
  }
  console.log(`i18n namespace check passed: ${scanned}.`)
}

main()
