import React from 'react'
import { assetUrl } from '../../utils/assets'

export function GraphicalIcon({
  icon,
  className = '',
  category,
  width = undefined,
  height = undefined,
  hex = false,
}: {
  icon: string
  className?: string
  category?: string
  width?: number
  height?: number
  hex?: boolean
}): JSX.Element {
  const classNames = ['c-icon', className, hex ? '--hex' : ''].filter(
    (className) => className.length > 0
  )

  const iconFile = assetUrl(`${category || 'icons'}/${icon}.svg`)

  return hex ? (
    <div className={classNames.join(' ')}>
      <img src={iconFile} alt="" role="presentation" />
    </div>
  ) : (
    <img
      src={iconFile}
      alt=""
      width={width}
      height={height}
      role="presentation"
      className={classNames.join(' ')}
    />
  )
}
