import React from 'react'
import { GraphicalIcon } from '.'
export function FilterFallback({
  icon,
  title,
  description,
  svgFilter,
}: {
  icon: string
  title: string
  description: string
  svgFilter?: string
}): JSX.Element {
  return (
    <div className="text-center py-40">
      <GraphicalIcon
        className={`w-[48px] h-[48px] m-auto mb-20 ${svgFilter}`}
        icon={icon}
      />
      <div className="text-h5 mb-8 text-textColor6">{title}</div>
      <div className="mb-20 text-textColor6 leading-160 text-16">
        {description}
      </div>
    </div>
  )
}
