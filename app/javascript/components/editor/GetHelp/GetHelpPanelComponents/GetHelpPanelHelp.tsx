import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GetHelpPanelProps } from '../GetHelpPanel'

export function GetHelpPanelHelp({
  helpHtml,
}: Pick<GetHelpPanelProps, 'helpHtml'>): JSX.Element {
  return (
    <div className="flex flex-col">
      <header className="flex items-center gap-12 mb-24">
        <GraphicalIcon
          icon="hints"
          category="graphics"
          height={40}
          width={40}
        />
        <h2 className="text-h3">Help</h2>
      </header>

      <div
        className="c-textual-content --base"
        dangerouslySetInnerHTML={{ __html: helpHtml }}
      />
    </div>
  )
}
