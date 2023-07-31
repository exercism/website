import React from 'react'
import { GraphicalIcon } from '@/components/common'

export function SectionHeader({
  title,
  description,
  icon,
  className,
}: {
  title: string
  className?: string
  description: string
  icon: string
}): JSX.Element {
  return (
    <div className={`flex flex-row items-start ${className}`}>
      <div className="p-8 mr-16">
        <GraphicalIcon height={32} width={32} icon={icon} />
      </div>
      <div>
        <h3 className="text-h3 font-bold">{title}</h3>
        <div className="text-p-base text-textColor6">{description}</div>
      </div>
    </div>
  )
}
