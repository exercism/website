import React from 'react'
import { assetUrl } from '../../utils/assets'

export function GraphicalIcon({
  icon,
  className = '',
  category,
  hex = false,
}: {
  icon: string
  className?: string
  category?: string
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
      role="presentation"
      className={classNames.join(' ')}
    />
  )
}
