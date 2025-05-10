import postcss from 'postcss'
import postcssNested from 'postcss-nested'
import { parse as parseSelector } from 'css-what'

type Styles = Record<string, string>

interface SimulatedNode {
  tag: string
  id?: string
  classes: string[]
  nthChild?: number
  parent?: SimulatedNode
}

export async function getStylesFromCss(
  css: string,
  targetSelector: string
): Promise<Styles> {
  const targetNode = buildSimulatedTree(targetSelector)
  const result = await postcss([postcssNested]).process(css, {
    from: undefined,
  })

  const styles: Styles = {}

  result.root.walkRules((rule) => {
    const raw = rule.selector
    const selectors = raw.split(',').map((s) => s.trim())

    for (const sel of selectors) {
      if (selectorMatchesNode(sel, targetNode)) {
        rule.walkDecls((decl) => {
          styles[decl.prop] = decl.value
        })
      }
    }
  })

  return styles
}

// converts a full selector string (e.g. #flag #top #rhs div) into a parent-linked tree
function buildSimulatedTree(selector: string): SimulatedNode {
  const parts = selector.split(' ').filter(Boolean)
  let parent: SimulatedNode | undefined = undefined
  let node: SimulatedNode | undefined

  for (const part of parts) {
    const current = parseSelectorPart(part)
    current.parent = parent
    parent = current
    node = current
  }

  if (!node) throw new Error('Invalid selector')
  return node
}

// parses a single CSS selector into a node
function parseSelectorPart(part: string): SimulatedNode {
  const tokens = parseSelector(part)[0]
  const node: SimulatedNode = {
    tag: '*',
    classes: [],
  }

  for (const token of tokens) {
    if (token.type === 'tag') node.tag = token.name
    if (token.type === 'attribute') {
      if (token.name === 'id') node.id = token.value
      if (token.name === 'class') node.classes.push(token.value)
    }
    if (
      token.type === 'pseudo' &&
      token.name === 'nth-child' &&
      typeof token.data === 'string'
    ) {
      const parsed = parseInt(token.data)
      if (!isNaN(parsed)) node.nthChild = parsed
    }
  }

  return node
}

// matches a CSS selector against a kinda "simulated DOM" node
function selectorMatchesNode(selector: string, node: SimulatedNode): boolean {
  const parts = selector.split(' ').filter(Boolean)
  let current: SimulatedNode | undefined = node

  for (let i = parts.length - 1; i >= 0; i--) {
    if (!current) return false

    const tokens = parseSelector(parts[i])[0]

    for (const token of tokens) {
      if (
        token.type === 'tag' &&
        token.name !== current.tag &&
        token.name !== '*'
      )
        return false
      if (token.type === 'attribute') {
        if (token.name === 'id' && token.value !== current.id) return false
        if (token.name === 'class' && !current.classes.includes(token.value))
          return false
      }
      if (token.type === 'pseudo' && token.name === 'nth-child') {
        if (!nthChildMatches(token.data as string, current.nthChild))
          return false
      }
    }

    current = current.parent
  }

  return true
}

// evals n-th logic
// we might need to add more of these if we want to support more pseudo-classes
function nthChildMatches(
  expected: string,
  actual: number | undefined
): boolean {
  if (!actual) return false
  if (expected === 'odd') return actual % 2 === 1
  if (expected === 'even') return actual % 2 === 0
  return parseInt(expected) === actual
}
