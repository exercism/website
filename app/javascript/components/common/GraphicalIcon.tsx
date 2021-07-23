import React from 'react'
import { IconCategory, loadIcon } from '../../utils/icon-loader'

export function GraphicalIcon({
  icon,
  className = '',
  category,
  hex = false,
}: {
  icon: string
  className?: string
  category?: IconCategory
  hex?: boolean
}) {
  const classNames = ['c-icon', className, hex ? '--hex' : ''].filter(
    (className) => className.length > 0
  )

  const iconFile = loadIcon(icon, category)

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
