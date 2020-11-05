import React from 'react'

export function Icon({ icon, alt }: { icon: string; alt: string }) {
  return (
    <svg className="c-icon" role="img">
      <title>{alt}</title>
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
