import React from 'react'
import { CompleteRepresentationData } from '../../../types'
import AutomationRules from './AutomationRules'
import HowImportant from './HowImportant'
import MentoringConversation from './MentoringConversation'

export function RightPane({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
  return (
    <div className="!h-100 py-16 flex flex-col justify-between">
      <div className="flex flex-col">
        <AutomationRules />
        <HowImportant />
      </div>
      <MentoringConversation data={data} />
    </div>
  )
}
