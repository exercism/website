import React from 'react'

export function GraphicalIcon({
  icon,
  className,
}: {
  icon: string
  className?: string
}) {
  return (
    <svg className={`c-icon ${className ? className : ''}`} role="presentation">
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
