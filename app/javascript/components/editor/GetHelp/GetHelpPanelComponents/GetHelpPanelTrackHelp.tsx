import React from 'react'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'

export function GetHelpPanelTrackHelp({
  helpHtml,
}: Pick<GetHelpPanelProps, 'helpHtml'>): JSX.Element {
  return (
    <GetHelpAccordionSkeleton title="Track help" icon={''}>
      <div
        className="c-textual-content --base pt-16"
        dangerouslySetInnerHTML={{ __html: helpHtml }}
      />
    </GetHelpAccordionSkeleton>
  )
}
