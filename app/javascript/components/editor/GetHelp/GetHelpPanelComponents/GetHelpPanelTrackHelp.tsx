import React from 'react'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { TrackIcon } from '@/components/common'

export function GetHelpPanelTrackHelp({
  helpHtml,
  track,
}: Pick<GetHelpPanelProps, 'helpHtml' | 'track'>): JSX.Element {
  return (
    <GetHelpAccordionSkeleton
      title={`${track.title} help`}
      icon={
        <TrackIcon
          title={track.title}
          iconUrl={track.iconUrl}
          className="w-[24px] h-[24px] mr-16"
        />
      }
    >
      <div
        className="c-textual-content --base pt-16"
        dangerouslySetInnerHTML={{ __html: helpHtml }}
      />
    </GetHelpAccordionSkeleton>
  )
}
