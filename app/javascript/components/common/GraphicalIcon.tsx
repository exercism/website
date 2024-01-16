import React from 'react'
import { assetUrl } from '../../utils/assets'

export function GraphicalIcon({
  icon,
  className = '',
  category,
  width = undefined,
  height = undefined,
  hex = false,
  alt,
}: {
  icon: string
  className?: string
  category?: string
  width?: number
  height?: number
  hex?: boolean
  alt?: string
}): JSX.Element {
  const classNames = ['c-icon', className, hex ? '--hex' : ''].filter(
    (className) => className.length > 0
  )

  const iconFile = assetUrl(`${category || 'icons'}/${icon}.svg`)

  return hex ? (
    <div className={classNames.join(' ')}>
      <img src={iconFile} alt="" />
    </div>
  ) : (
    <img
      src={iconFile}
      alt={alt || ''}
      width={width}
      height={height}
      className={classNames.join(' ')}
    />
  )
}

export default GraphicalIcon
