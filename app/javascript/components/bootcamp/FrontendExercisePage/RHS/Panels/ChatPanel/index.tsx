import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../RHS'
import { Chat } from './AiChat'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'

export function ChatPanel() {
  const { links, solution, htmlEditorRef, jsEditorRef, cssEditorRef } =
    React.useContext(FrontendExercisePageContext)
  return (
    <Tab.Panel
      className="h-full"
      alwaysAttachToDOM
      id="chat"
      context={TabsContext}
    >
      <Chat
        code={{
          css: cssEditorRef.current?.state.doc.toString(),
          html: htmlEditorRef.current?.state.doc.toString(),
          js: jsEditorRef.current?.state.doc.toString(),
        }}
        links={links}
        solutionUuid={solution.uuid}
        messages={solution.messages}
      />
    </Tab.Panel>
  )
}
