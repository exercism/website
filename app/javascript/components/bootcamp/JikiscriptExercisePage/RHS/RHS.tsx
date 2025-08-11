import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { createContext, useContext, useState } from 'react'
import { Instructions } from './Instructions/Instructions'
import { Logger } from './Logger/Logger'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
import { Resizer, useResizablePanels } from '../hooks/useResize'
import { Tabs } from './Tabs'
import { Tab, TabContext } from '@/components/common/Tab'
import { Chat } from '../../FrontendExercisePage/RHS/Panels/ChatPanel/AiChat'

type TabIndex = 'instructions' | 'chat'

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export function RHS({ width }: { width: number }) {
  const { exercise, links, solution, editorView } = useContext(
    JikiscriptExercisePageContext
  )
  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 200,
    secondaryMinSize: 200,
    direction: 'vertical',
    localStorageId: 'solve-exercise-page-rhs-height',
  })

  const [tab, setTab] = useState<TabIndex>('instructions')
  return (
    <div className={assembleClassNames('page-body-rhs')} style={{ width }}>
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
              <Instructions
                exerciseTitle={exercise.title}
                exerciseInstructions={exercise.introductionHtml}
                height={exercise.language === 'javascript' ? TopHeight : '100%'}
              />

              {exercise.language === 'javascript' && (
                <>
                  <Resizer
                    direction="horizontal"
                    handleMouseDown={handleHeightChangeMouseDown}
                    className="c-logger-resizer"
                  />
                  <Logger height={BottomHeight} />
                </>
              )}
            </Tab.Panel>

            <Tab.Panel
              className="h-full"
              alwaysAttachToDOM
              id="chat"
              context={TabsContext}
            >
              <Chat
                code={{
                  // TODO: make decisions here regarding the key name
                  jiki: editorView?.state.doc.toString(),
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
  )
}
