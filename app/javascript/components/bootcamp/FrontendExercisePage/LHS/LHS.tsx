import React, { createContext, useCallback, useContext, useState } from 'react'
import { TabContext } from '@/components/common/Tab'
import { Tabs } from './Tabs'
import { Panels } from './Panels/Panels'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { updateIFrame } from '../utils/updateIFrame'
import { parseJS } from '../utils/parseJS'
import { cleanUpEditorErrorState, showJsError } from './showJsError'
import { useHandleJsErrorMessage } from './useHandleJsErrorMessage'
import { useFrontendExercisePageStore } from '../store/frontendExercisePageStore'
import toast from 'react-hot-toast'
import { validateHtml } from './validateHtml'
import { wrapJSCode } from './wrapJSCode'

export type TabIndex = 'html' | 'css' | 'javascript'

export const TabsContext = createContext<TabContext>({
  current: 'html',
  switchToTab: () => {},
})

export function LHS() {
  const [tab, setTab] = useState<TabIndex>('html')

  const {
    cssEditorRef,
    htmlEditorRef,
    jsEditorRef,
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    exercise,
    code,
  } = useContext(FrontendExercisePageContext)

  const {
    toggleDiffActivity,
    isDiffActive,
    isOverlayActive,
    toggleOverlayActivity,
    RHSActiveTab,
    setRHSActiveTab,
    setLogs,
    panelSizes: { LHSWidth },
  } = useFrontendExercisePageStore()

  const handleToggleDiff = useCallback(() => {
    toggleDiffActivity()
    setRHSActiveTab('output')
  }, [])
  const handleToggleOverlay = useCallback(() => {
    toggleOverlayActivity()
    setRHSActiveTab('output')
  }, [])

  const handleRunCode = useCallback(() => {
    if (!jsEditorRef.current || !htmlEditorRef.current) return

    const htmlText = htmlEditorRef.current.state.doc.toString()
    const isHTMLValid = validateHtml(htmlText)

    if (!isHTMLValid.isValid) {
      setTab('html')
      toast.error(
        `Your HTML is invalid. Please check the linter and look for unclosed tags.`
      )
      return
    }

    const jsView = jsEditorRef.current
    const jsCode = jsEditorRef.current.state.doc.toString()

    const result = parseJS(jsView.state.doc.toString())
    switch (result.status) {
      case 'success':
        const fullScript = wrapJSCode(jsCode)
        const expectedScript = wrapJSCode(exercise.config.expected.js)
        // we'll only run the JS code if:
        // 1. someone clicks the `Run Code` button and
        // 2. there are no parsing errors
        const runCode = updateIFrame(
          actualIFrameRef,
          {
            script: fullScript,
            html: htmlEditorRef.current?.state.doc.toString(),
            css: cssEditorRef.current?.state.doc.toString(),
          },
          code
        )

        const runRefCode = updateIFrame(
          expectedIFrameRef,
          {
            ...exercise.config.expected,
            script: expectedScript,
          },
          code
        )
        const runExpectedCode = updateIFrame(
          expectedReferenceIFrameRef,
          {
            ...exercise.config.expected,
            script: expectedScript,
          },
          code
        )

        if (RHSActiveTab === 'instructions') {
          setRHSActiveTab('output')
        }
        setLogs([])
        runCode?.()
        runRefCode?.()
        runExpectedCode?.()
        break
      case 'error':
        setTab('javascript')
        showJsError(jsView, result.error)
        break
    }
  }, [RHSActiveTab])

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
      <div style={{ width: LHSWidth }} className="control-buttons-container">
        <button onClick={handleRunCode} className="btn-primary btn-m">
          Run Code
        </button>

        <div className="flex gap-8">
          <button onClick={handleToggleOverlay} className="btn-secondary btn-m">
            Overlay: {isOverlayActive ? 'on' : 'off'}
          </button>
          <button onClick={handleToggleDiff} className="btn-secondary btn-m">
            Diff: {isDiffActive ? 'on' : 'off'}
          </button>
        </div>
      </div>
    </div>
  )
}
