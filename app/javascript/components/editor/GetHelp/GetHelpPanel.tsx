import React from 'react'
import { TabsContext } from '@/components/Editor'
import { Tab } from '@/components/common'
import * as Component from './GetHelpPanelComponents'
import type { Assignment } from '../types'

export type GetHelpPanelProps = {
  helpHtml: string
  assignment: Assignment
}

export function GetHelpPanel({
  helpHtml,
  assignment,
}: GetHelpPanelProps): JSX.Element {
  return (
    <Tab.Panel id="get-help" context={TabsContext}>
      <div className="px-24 flex flex-col gap-24">
        <Component.Hints assignment={assignment} />
        <Component.Help helpHtml={helpHtml} />
      </div>
    </Tab.Panel>
  )
}
