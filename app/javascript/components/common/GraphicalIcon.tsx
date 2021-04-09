import React from 'react'

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
}) {
  const classNames = ['c-icon', className, hex ? '--hex' : ''].filter(
    (className) => className.length > 0
  )

  const iconFile = require(`../../images/${category || 'icons'}/${icon}.svg`)

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
