import React, { createContext, useCallback, useContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { updateIFrame } from '../utils/updateIFrame'

type TabIndex = 'html' | 'css' | 'javascript'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function LHS() {
  const [tab, setTab] = useState<TabIndex>('html')

  const { cssEditorRef, htmlEditorRef, jsEditorRef, actualIFrameRef } =
    useContext(FrontendExercisePageContext)

  const handleRunCode = useCallback(() => {
    // we only want to run JS code when we click this button
    // so we start with populating the iframe with JS content
    updateIFrame(actualIFrameRef, {
      js: jsEditorRef.current?.state.doc.toString(),
      html: htmlEditorRef.current?.state.doc.toString(),
      css: cssEditorRef.current?.state.doc.toString(),
    })
  }, [])

  return (
    <div className="page-body-lhs">
      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (id: string) => {
            setTab(id as TabIndex)
          },
        }}
      >
        <div className="c-iteration-pane">
          <Tabs />
          <Panels />
        </div>
      </TabsContext.Provider>
      <div className="flex">
        <button onClick={handleRunCode} className="btn-primary btn-m">
          Run Code
        </button>
      </div>
    </div>
  )
}
