import * as csstree from 'css-tree'
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
  // add more as needed
}

export function exactPropertiesUsed(css: string, allowed: string[]): boolean {
  const ast = csstree.parse(css)
  const usedProps = new Set<string>()

  csstree.walk(ast, {
    visit: 'Declaration',
    enter(node) {
      if (node.type === 'Declaration') {
        usedProps.add(node.property)
      }
    },
  })

  // Expand the allowed properties based on property groups
  const expandedAllowed = new Set<string>()
  for (const prop of allowed) {
    const group = propertyGroups[prop]
    if (group) {
      group.forEach((p) => expandedAllowed.add(p))
    } else {
      expandedAllowed.add(prop)
    }
  }

  // Check that every used property is in the expanded allowed set
  for (const used of usedProps) {
    if (!expandedAllowed.has(used)) {
      return false
    }
  }

  return true
}
