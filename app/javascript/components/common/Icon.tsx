import * as React from 'react'

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
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const iconFile = require(`../../images/${category}/${icon}.svg`)

  return <img src={iconFile} alt={alt} className={classNames.join(' ')} />
}
