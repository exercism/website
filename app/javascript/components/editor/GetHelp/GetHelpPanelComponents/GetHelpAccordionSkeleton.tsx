import { GraphicalIcon } from '@/components/common'
import React from 'react'

type GetHelpAccordionSkeletonProps = Partial<
  Record<'title' | 'icon' | 'iconSlug', string>
> & {
  children: React.ReactElement
}

export function GetHelpAccordionSkeleton({
  title,
  icon,
  children,
}: GetHelpAccordionSkeletonProps): JSX.Element {
  return (
    <details className="c-details border-t-1 border-borderColor6 py-16 px-24 ">
      <summary className="flex items-center">
        <GraphicalIcon
          icon={icon || 'help'}
          width={24}
          height={24}
          className="mr-16 filter-textColor6"
        />
        <div className="flex items-center justify-between w-100">
          <span className="text-h4">{title}</span>
          <span className="--closed-icon">
            <GraphicalIcon
              icon="chevron-right"
              className="filter-textColor6"
              height={12}
              width={12}
            />
          </span>
          <span className="--open-icon">
            <GraphicalIcon
              icon="chevron-down"
              className="filter-textColor6"
              height={12}
              width={12}
            />
          </span>
        </div>
      </summary>
      {children}
    </details>
  )
}
