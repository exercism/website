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
  return (
    <svg className={`c-icon ${className ? className : ''}`} role="img">
      <title>{alt}</title>
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
