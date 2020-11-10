import React from 'react'

export function GraphicalIcon({
  icon,
  className,
}: {
  icon: string
  className?: string
}) {
  let classNames = ['c-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <svg className={classNames.join(' ')} role="presentation">
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
