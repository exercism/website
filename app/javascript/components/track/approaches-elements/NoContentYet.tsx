import { GraphicalIcon } from '@/components/common'
import React from 'react'

type NoContentYetProps = {
  exerciseTitle: string
  contentType: string
  children: React.ReactNode
}
export function NoContentYet({
  exerciseTitle,
  contentType,
  children,
}: NoContentYetProps): JSX.Element {
  return (
    <div className="text-textColor6 flex flex-col items-center bg-bgGray p-24 rounded-8">
      <GraphicalIcon
        icon="sad-exercism"
        height={48}
        width={48}
        className="filter-textColor6 mb-8"
      />
      <div className="text-label-timestamp text-16 mb-4 font-semibold text-center">
        There are no {contentType} for {exerciseTitle}.
      </div>
      <div className="flex flex-row text-15 leading-150">{children}</div>
    </div>
  )
}
