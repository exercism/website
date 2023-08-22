import React from 'react'
import { TabsContext } from '@/components/Editor'
import { GraphicalIcon, Tab } from '@/components/common'

export function GetHelpPanel({
  children,
  helpHtml,
}: {
  children: React.ReactChild
  helpHtml: string
}): JSX.Element {
  return (
    <Tab.Panel id="get-help" context={TabsContext}>
      {children}

      <div className="px-24">
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
    </Tab.Panel>
  )
}
