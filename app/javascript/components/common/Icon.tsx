import * as React from 'react'
import { assetUrl } from '../../utils/assets'

export function Icon({
  icon,
  alt,
  className,
  category = 'icons',
  width = undefined,
  height = undefined,
  title,
}: {
  icon: string
  alt: string
  className?: string
  category?: string
  width?: number
  height?: number
  title?: string
}): JSX.Element {
  const classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }
  const iconFile = assetUrl(`${category}/${icon}.svg`)

  return (
    <img
      src={iconFile}
      alt={alt}
      height={height}
      width={width}
      title={title}
      className={classNames.join(' ')}
    />
  )
}

export default Icon
