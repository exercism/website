import React from 'react'

export function Icon({
  icon,
  alt,
  className,
}: {
  icon: string
  alt: string
  className?: string
}) {
  let classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <svg className={classNames.join(' ')} role="img">
      <title>{alt}</title>
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
