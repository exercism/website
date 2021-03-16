import React from 'react'

export function GraphicalIcon({
  icon,
  className,
  category,
}: {
  icon: string
  className?: string
  category?: string
}) {
  let classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  const iconFile = require(`../../images/${category || 'icons'}/${icon}.svg`)

  return (
    <img src={iconFile} role="presentation" className={classNames.join(' ')} />
  )
}
