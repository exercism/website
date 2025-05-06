import postcss from 'postcss'
import postcssNested from 'postcss-nested'

export async function onlyPropertiesUsed(
  css: string,
  allowed: string[]
): Promise<boolean> {
  const usedProps = new Set<string>()

  const result = await postcss([postcssNested]).process(css, {
    from: undefined,
  })


  result.root.walkDecls((decl) => {
    usedProps.add(decl.prop)
  })

  for (const used of usedProps) {
    if (!allowed.includes(used)) {
      return false
    }
  }

  return true
}
