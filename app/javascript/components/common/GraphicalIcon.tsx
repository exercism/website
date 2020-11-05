import React from 'react'

export function GraphicalIcon({ icon }: { icon: string }) {
  return (
    <svg className="c-graphical-icon" role="presentation">
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
