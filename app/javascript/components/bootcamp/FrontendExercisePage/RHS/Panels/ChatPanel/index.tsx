import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../RHS'
import { Chat } from './AiChat'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'

export function ChatPanel() {
  const { links, solution } = React.useContext(FrontendExercisePageContext)
  return (
    <Tab.Panel
      className="h-full"
      alwaysAttachToDOM
      id="chat"
      context={TabsContext}
    >
      <Chat
        links={links}
        solutionUuid={solution.uuid}
        messages={solution.messages}
      />
    </Tab.Panel>
  )
}
