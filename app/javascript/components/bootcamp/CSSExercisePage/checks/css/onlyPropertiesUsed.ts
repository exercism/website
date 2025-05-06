import * as csstree from 'css-tree'

export function onlyPropertiesUsed(css: string, allowed: string[]): boolean {
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

  for (const used of usedProps) {
    if (!allowed.includes(used)) {
      return false
    }
  }

  return true
}
