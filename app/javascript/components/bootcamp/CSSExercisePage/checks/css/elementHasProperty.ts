import postcss from 'postcss'
import postcssNesting from 'postcss-nesting'

function normalize(s: string): string {
  return s.replace(/\s+/g, ' ').trim()
}

// Crude match: checks if target selector appears in order within full selector
function selectorRoughlyMatches(sel: string, target: string): boolean {
  const normSel = normalize(sel)
  const normTarget = normalize(target)
  return normSel.includes(normTarget)
}

export async function findPropertyDeclarations(
  css: string,
  targetSelector: string,
  propertyName: string
): Promise<string[]> {
  const result: string[] = []

  const processed = await postcss([postcssNesting]).process(css, {
    from: undefined,
  })

  processed.root.walkRules((rule) => {
    const selectors = rule.selectors?.map(normalize) ?? []

    const matches = selectors.some((sel) =>
      selectorRoughlyMatches(sel, targetSelector)
    )

    if (!matches) return

    rule.walkDecls((decl) => {
      if (decl.prop === propertyName) {
        result.push(`${decl.prop}: ${decl.value}`)
      }
    })
  })

  return result
}

export async function elementHasProperty(
  css: string,
  selector: string,
  property: string
): Promise<boolean> {
  const decls = await findPropertyDeclarations(css, selector, property)
  return decls.length > 0
}

export async function elementHasPropertyValue(
  css: string,
  selector: string,
  property: string,
  value: string
): Promise<boolean> {
  const declarations = await findPropertyDeclarations(css, selector, property)
  const normalizedValue = normalize(value)
  return declarations.some((decl) => decl.endsWith(normalizedValue))
}
