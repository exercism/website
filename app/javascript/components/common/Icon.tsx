import * as React from 'react'
import { assetUrl } from '../../utils/assets'

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
  const iconFile = assetUrl(`${category}/${icon}.svg`)

  return <img src={iconFile} alt={alt} className={classNames.join(' ')} />
}
