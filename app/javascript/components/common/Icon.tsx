import * as React from 'react'
import manifest from '../../.manifest.json'

console.log(manifest)

export function Icon({
  icon,
  alt,
  className,
  category = 'icons',
}: {
  icon: string
  alt: string
  className?: string
  category?: string
}): JSX.Element {
  const classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }
  const iconFile = manifest[`images/${category}/${icon}.svg`]

  return <img src={iconFile} alt={alt} className={classNames.join(' ')} />
}
