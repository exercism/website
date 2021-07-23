import React from 'react'
import { IconCategory, loadIconFile } from '../../utils/icon-file'

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

  const iconFile = loadIconFile(icon, category)

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
