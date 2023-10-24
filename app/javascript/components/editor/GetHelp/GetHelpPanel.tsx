import React from 'react'
import { TabsContext } from '@/components/Editor'
import { Tab } from '@/components/common'
import * as Component from './GetHelpPanelComponents'
import type { Assignment } from '../types'
import { Track } from '@/components/types'

export type GetHelpPanelProps = {
  helpHtml: string
  assignment: Assignment
  links: Record<'discordRedirectPath' | 'forumRedirectPath', string>
  track: Pick<Track, 'title' | 'iconUrl'>
}

export function GetHelpPanel({
  helpHtml,
  assignment,
  links,
  track,
}: GetHelpPanelProps): JSX.Element {
  return (
    <Tab.Panel id="get-help" context={TabsContext}>
      <div className="pb-12 flex flex-col">
        <Component.Hints assignment={assignment} />
        <Component.CommunityHelp links={links} />
        <Component.TrackHelp helpHtml={helpHtml} track={track} />
      </div>
    </Tab.Panel>
  )
}
