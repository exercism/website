import React from 'react'

export function Icon({
  icon,
  alt,
  className,
  category,
}: {
  icon: string
  alt: string
  className?: string
  category?: string
}) {
  let classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }
  const iconFile = require(`../../images/${category || 'icons'}/${icon}.svg`)

  return <img src={iconFile} alt={alt} className={classNames.join(' ')} />
}
