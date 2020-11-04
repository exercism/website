import React from 'react'

export function GraphicalIcon({ icon }: { icon: string }) {
  return (
    <svg className="c-graphical-icon" role="img">
      <use xlinkHref={`#${icon}`} />
    </svg>
  )
}
