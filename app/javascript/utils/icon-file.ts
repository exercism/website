// eslint-disable @typescript-eslint/no-var-requires

export type IconCategory = 'graphics' | 'icons'

export function loadIconFile(icon: string, category?: IconCategory) {
  if (category === 'graphics')
    return require(`../../../website-icons/graphics/${icon}.svg`)

  return require(`../../../website-icons/icons/${icon}.svg`)
}
