import postcss from 'postcss'
import postcssNesting from 'postcss-nesting'

const propertyGroups: Record<string, string[]> = {
  padding: [
    'padding',
    'padding-top',
    'padding-right',
    'padding-bottom',
    'padding-left',
  ],
  margin: [
    'margin',
    'margin-top',
    'margin-right',
    'margin-bottom',
    'margin-left',
  ],
  border: [
    'border',
    'border-top',
    'border-right',
    'border-bottom',
    'border-left',
  ],
  background: [
    'background',
    'background-color',
    'background-image',
    'background-repeat',
    'background-position',
    'background-size',
  ],
}

export async function onlyPropertyGroupsUsed(
  css: string,
  allowed: string[]
): Promise<boolean> {
  const usedProps = new Set<string>()

  const result = await postcss([postcssNesting]).process(css, {
    from: undefined,
  })

  result.root.walkDecls((decl) => {
    usedProps.add(decl.prop)
  })

  const expandedAllowed = new Set<string>()
  for (const prop of allowed) {
    const group = propertyGroups[prop]
    if (group) {
      group.forEach((p) => expandedAllowed.add(p))
    } else {
      expandedAllowed.add(prop)
    }
  }

  for (const used of usedProps) {
    if (!expandedAllowed.has(used)) {
      return false
    }
  }

  return true
}
