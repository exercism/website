import React, { createContext, useContext } from 'react'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { ActualOutput } from '../ActualOutput'
import { ExpectedOutput } from '../ExpectedOutput'
import { Instructions } from '../Instructions'
import { Tab, TabContext } from '@/components/common'
import { Tabs } from './Tabs'
import { Chat } from '../../FrontendExercisePage/RHS/Panels/ChatPanel/AiChat'
import { CSSExercisePageContext } from '../CSSExercisePageContext'

type TabIndex = 'instructions' | 'chat'

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export function RHS() {
  const {
    panelSizes: { RHSWidth },
  } = useCSSExercisePageStore()

  const { htmlEditorRef, cssEditorRef, solution, links } = useContext(
    CSSExercisePageContext
  )

  const [tab, setTab] = React.useState<TabIndex>('instructions')
  return (
    <div className="page-body-rhs" style={{ width: RHSWidth }}>
      <div className="flex gap-8 h-full">
        <div className="flex flex-col gap-12">
          <ExpectedOutput />
          <ActualOutput />
        </div>

        <TabsContext.Provider
          value={{
            current: tab,
            switchToTab: (id: string) => {
              setTab(id as TabIndex)
            },
          }}
        >
          <div className="c-iteration-pane h-100">
            <Tabs />
            <div className="panels h-100 overflow-auto">
              <Tab.Panel id="instructions" context={TabsContext}>
                <Instructions />
              </Tab.Panel>

              <Tab.Panel
                className="h-full"
                alwaysAttachToDOM
                id="chat"
                context={TabsContext}
              >
                <Chat
                  code={{
                    html: htmlEditorRef.current?.state.doc.toString(),
                    css: cssEditorRef.current?.state.doc.toString(),
                  }}
                  links={links}
                  solutionUuid={solution.uuid}
                  messages={solution.messages}
                />
              </Tab.Panel>
            </div>
          </div>
        </TabsContext.Provider>
      </div>
    </div>
  )
}
