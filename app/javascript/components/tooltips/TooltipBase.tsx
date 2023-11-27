import React from 'react'

export function TooltipBase({
  children,
  width,
}: {
  children: React.ReactNode
  width: string | number
}) {
  return (
    <div className="c-tooltip-base" style={{ width }}>
      {children}
    </div>
  )
}
