import * as csstree from 'css-tree'

function normalize(s: string): string {
  return s.replace(/\s+/g, ' ').trim()
}

// Crude match: checks if target selector appears in order within full selector
function selectorRoughlyMatches(sel: string, target: string): boolean {
  const normSel = normalize(sel)
  const normTarget = normalize(target)
  return normSel.includes(normTarget)
}

export function findPropertyDeclarations(
  css: string,
  targetSelector: string,
  propertyName: string
): string[] {
  const result: string[] = []
  const ast = csstree.parse(css)

  csstree.walk(ast, {
    visit: 'Rule',
    enter(node) {
      if (node.type !== 'Rule' || node.prelude.type !== 'SelectorList') return

      const selectorText = csstree.generate(node.prelude)
      const selectors = selectorText.split(',').map(normalize)

      const matches = selectors.some((sel) =>
        selectorRoughlyMatches(sel, targetSelector)
      )

      if (!matches || node.block.type !== 'Block') return

      for (const child of node.block.children) {
        if (child.type === 'Declaration' && child.property === propertyName) {
          const value = csstree.generate(child.value)
          result.push(`${child.property}: ${value}`)
        }
      }
    },
  })

  return result
}

export function elementHasProperty(
  css: string,
  selector: string,
  property: string
): boolean {
  return findPropertyDeclarations(css, selector, property).length > 0
}

export function elementHasPropertyValue(
  css: string,
  selector: string,
  property: string,
  value: string
): boolean {
  const declarations = findPropertyDeclarations(css, selector, property)
  const normalizedValue = normalize(value)
  return declarations.some((decl) => decl.endsWith(normalizedValue))
}
