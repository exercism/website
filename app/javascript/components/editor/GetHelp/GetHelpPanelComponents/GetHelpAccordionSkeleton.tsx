import { GraphicalIcon } from '@/components/common'
import React from 'react'

type GetHelpAccordionSkeletonProps = {
  title: string
  children: React.ReactElement
  icon?: React.ReactElement
  iconSlug?: string
  className?: string
}

export function GetHelpAccordionSkeleton({
  title,
  icon,
  iconSlug,
  children,
  className,
}: GetHelpAccordionSkeletonProps): JSX.Element {
  return (
    <details
      className={`c-details border-t-1 border-borderColor6 py-16 px-24 ${
        className ?? ''
      }`}
      open
    >
      <summary className="flex items-center">
        {icon || (
          <GraphicalIcon
            icon={iconSlug || 'help'}
            width={24}
            height={24}
            className="mr-16 filter-textColor6"
          />
        )}
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
