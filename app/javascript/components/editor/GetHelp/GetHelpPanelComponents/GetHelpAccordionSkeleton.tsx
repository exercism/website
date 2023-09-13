import { GraphicalIcon } from '@/components/common'
import React from 'react'

type GetHelpAccordionSkeletonProps = Partial<
  Record<'title' | 'icon', string>
> & {
  children: React.ReactElement
}

export function GetHelpAccordionSkeleton({
  title,
  icon,
  children,
}: GetHelpAccordionSkeletonProps): JSX.Element {
  return (
    <details className="c-details">
      <summary className="flex items-center">
        <GraphicalIcon
          icon={icon || 'help'}
          width={32}
          height={32}
          className="mr-16"
        />
        <div className="flex items-center justify-between w-100">
          <span className="text-h4">{title}</span>
          <span className="--closed-icon">
            <GraphicalIcon icon="chevron-right" height={12} width={12} />
          </span>
          <span className="--open-icon">
            <GraphicalIcon icon="chevron-down" height={12} width={12} />
          </span>
        </div>
      </summary>
      {children}
    </details>
  )
}
