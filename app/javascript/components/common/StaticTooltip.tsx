import { assembleClassNames } from '@/utils/assemble-classnames'
import React from 'react'

export function StaticTooltip({
  children,
  className,
  style,
}: {
  children: React.ReactNode
  className?: string
  style?: React.CSSProperties
}) {
  return (
    <div
      style={style}
      className={assembleClassNames(
        'absolute left-1/2 -top-10 -translate-x-1/2 -translate-y-full hidden group-hover:block z-tooltip',
        className
      )}
      role="tooltip"
    >
      {children}
    </div>
  )
}
