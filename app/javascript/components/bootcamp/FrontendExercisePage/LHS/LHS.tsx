import React, { createContext, useCallback, useContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { updateIFrame } from '../utils/updateIFrame'
import { showError } from '../../JikiscriptExercisePage/utils/showError'
import { scrollToLine } from '../../JikiscriptExercisePage/CodeMirror/scrollToLine'
import { addUnderlineEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/underlineRange'

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

    const jsView = jsEditorRef.current

    if (!jsView) return

    const jsCode = jsEditorRef.current.state.doc.toString()
    updateIFrame(actualIFrameRef, {
      js: jsCode,
      html: htmlEditorRef.current?.state.doc.toString(),
      css: cssEditorRef.current?.state.doc.toString(),
    })

    const result = parseJS(jsView.state.doc.toString())
    if (result.status === 'error') {
      setTab('javascript')

      scrollToLine(jsEditorRef.current, result.error.lineNumber)
      const absolutePosition =
        jsEditorRef.current.state.doc.line(result.error.lineNumber).from +
        result.error.colNumber
      jsView.dispatch({
        effects: addUnderlineEffect.of({
          from: absolutePosition,
          to: absolutePosition + 1,
        }),
      })

      // setUnderlineRange({ from, to })
      // setHighlightedLine(line)
      // setHighlightedLineColor(ERROR_HIGHLIGHT_COLOR)
      // setInformationWidgetData({ html, line, status })
      // setShouldShowInformationWidget(true)
      console.log(
        result.error.message,
        result.error.lineNumber,
        result.error.colNumber
      )
    }

    // TODO: show error here
    // 1. if there is an error, show the JS tab ✅
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

import * as acorn from 'acorn'

export function parseJS(code: string | undefined) {
  console.log('CODE:', code)
  try {
    acorn.parse(code || '', {
      ecmaVersion: 2020,
      sourceType: 'module',
      locations: true,
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
        lineNumber: loc.line,
        colNumber: loc.column,
        type: err.name,
      },
    }
  }
}

// Test function to demonstrate
function testParse(code: string) {
  console.log('Parsing code:', code)
  const result = parseJS(code)
  console.log('Result:', result)
}

// Test cases
testParse(`le thought = "why are strings always green"`)
testParse(`let thought = "why are strings always green"`)
