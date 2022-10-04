import { GraphicalIcon, Icon } from '@/components/common'
import React from 'react'

type NoContentYetProps = {
  exerciseTitle: string
  contentType: string
}
export function NoContentYet({
  exerciseTitle,
  contentType,
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
      <div className="flex flex-row text-15 leading-150">
        Got one in mind?&nbsp;
        <a className="flex">
          <span className="underline">Post it here.</span>&nbsp;
          <Icon
            className="filter-textColor6"
            icon={'new-tab'}
            alt={'open in a new tab'}
          />
        </a>
      </div>
    </div>
  )
}
