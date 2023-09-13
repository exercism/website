import React from 'react'
import { TabsContext } from '@/components/Editor'
import { Tab } from '@/components/common'
import * as Component from './GetHelpPanelComponents'
import type { Assignment } from '../types'

export type GetHelpPanelProps = {
  helpHtml: string
  assignment: Assignment
  links: Record<'discordRedirectPath' | 'forumRedirectPath', string>
}

export function GetHelpPanel({
  helpHtml,
  assignment,
  links,
}: GetHelpPanelProps): JSX.Element {
  return (
    <Tab.Panel id="get-help" context={TabsContext}>
      <div className="p-24 flex flex-col gap-24">
        <Component.Hints assignment={assignment} />
        <Component.TrackHelp helpHtml={helpHtml} />
        <Component.CommunityHelp links={links} />
      </div>
    </Tab.Panel>
  )
}
