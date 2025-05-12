import React, { createContext, useCallback, useContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { updateIFrame } from '../utils/updateIFrame'
import { parseJS } from '../utils/parseJS'
import { cleanUpEditorErrorState, showJsError } from './showJsError'
import { useHandleJsErrorMessage } from './useHandleJsErrorMessage'

export type TabIndex = 'html' | 'css' | 'javascript'

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function LHS() {
  const [tab, setTab] = useState<TabIndex>('html')

  const { cssEditorRef, htmlEditorRef, jsEditorRef, actualIFrameRef } =
    useContext(FrontendExercisePageContext)

  const handleRunCode = useCallback(() => {
    if (!jsEditorRef.current) return

    const jsView = jsEditorRef.current
    const jsCode = jsEditorRef.current.state.doc.toString()

    const result = parseJS(jsView.state.doc.toString())
    switch (result.status) {
      case 'success':
        // we'll only run the JS code if:
        // 1. someone clicks the `Run Code` button and
        // 2. there are no parsing errors
        updateIFrame(actualIFrameRef, {
          js: jsCode,
          html: htmlEditorRef.current?.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
        })
        break
      case 'error':
        setTab('javascript')
        showJsError(jsView, result.error)
        break
    }
  }, [])

  useHandleJsErrorMessage({ jsViewRef: jsEditorRef, setTab })

  return (
    <div className="page-body-lhs">
      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (id: string) => {
            cleanUpEditorErrorState(jsEditorRef.current)
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
