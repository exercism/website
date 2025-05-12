import React, { createContext, useCallback, useContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { updateIFrame } from '../utils/updateIFrame'
import * as acorn from 'acorn'
import { showError } from '../../JikiscriptExercisePage/utils/showError'

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

    const jsCode = jsEditorRef.current?.state.doc.toString()
    updateIFrame(actualIFrameRef, {
      js: jsCode,
      html: htmlEditorRef.current?.state.doc.toString(),
      css: cssEditorRef.current?.state.doc.toString(),
    })

    const result = parseJS('function () {')
    if (result.status === 'error') {
      console.error(
        result.error.message,
        result.error.lineNumber,
        result.error.colNumber
      )
    }

    // TODO: show error here
    // 1. if there is an error, show the JS tab
    // 2. instead of putting in tons of state in the store, and reflecting those,
    //    try to use jsEditorRef.current and its inner state
    // 3. clean it up on keystroke in JavascriptEditor
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

export function parseJS(code: string | undefined) {
  try {
    acorn.parse(code || '', {
      ecmaVersion: 2020,
      sourceType: 'module',
    })
    return {
      status: 'success' as const,
    }
  } catch (err: any) {
    const loc = err.loc || { line: 1, column: 0 }

    return {
      status: 'error' as const,
      cleanup: () => {},
      error: {
        message: err.message.replace(/\s*\(\d+:\d+\)$/, ''),
        lineNumber: loc.line - 1,
        colNumber: loc.column,
        type: err.name,
      },
    }
  }
}
