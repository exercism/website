import postcss from 'postcss'
import postcssNested from 'postcss-nested'

export async function illegalPropertiesUsed(
  css: string,
  allowed: string[]
): Promise<string | null> {
  const usedProps = new Set<string>()

  const result = await postcss([postcssNested]).process(css, {
    from: undefined,
  })

  result.root.walkDecls((decl) => {
    usedProps.add(decl.prop)
  })

  for (const used of usedProps) {
    if (!allowed.includes(used)) {
      return used
    }
  }

  return null
}
