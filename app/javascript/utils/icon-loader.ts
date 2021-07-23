// eslint-disable @typescript-eslint/no-var-requires

export type IconCategory = 'graphics' | 'icons'

const missingIcon = require(`../images/missing.svg`)

export function loadIcon(icon: string, category?: IconCategory) {
  try {
    if (category === 'graphics') {
      return require(`../../../website-icons/graphics/${icon}.svg`)
    }

    return require(`../../../website-icons/icons/${icon}.svg`)
  } catch {
    return missingIcon
  }
}
