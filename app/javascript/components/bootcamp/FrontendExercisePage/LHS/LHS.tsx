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
import { wrapJSCode } from './wrapJSCode'
import { validateHtml5 } from '../../common/validateHtml5/validateHtml5'
import { normalizeHtmlText } from '../../common/validateHtml5/normalizeHtmlText'
import { submitCode } from '../../JikiscriptExercisePage/hooks/useConstructRunCode/submitCode'
import { getCodeMirrorFieldValue } from '../../JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'
import { readOnlyRangesStateField } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'

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
    links,
    jsCodeRunId,
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

    const htmlCode = htmlEditorRef.current.state.doc.toString()

    if (htmlCode.length > 0) {
      const normalizedHtml = normalizeHtmlText(htmlCode)
      const isHTMLValid = validateHtml5(normalizedHtml)

      if (!isHTMLValid.isValid) {
        setTab('html')
        toast.error(
          `Your HTML is invalid (${isHTMLValid.errorMessage}). Please check the linter and look for hints on how to fix it.`
        )
        return
      }
    }

    const cssCode = cssEditorRef.current?.state.doc.toString()

    const jsView = jsEditorRef.current
    const jsCode = jsEditorRef.current.state.doc.toString()

    const cssReadonlyRanges = getCodeMirrorFieldValue(
      cssEditorRef.current,
      readOnlyRangesStateField
    )
    const htmlReadonlyRanges = getCodeMirrorFieldValue(
      htmlEditorRef.current,
      readOnlyRangesStateField
    )
    const jsReadonlyRanges = getCodeMirrorFieldValue(
      jsEditorRef.current,
      readOnlyRangesStateField
    )

    const submittedCode = JSON.stringify({
      html: htmlCode,
      css: cssCode,
      js: jsCode,
    })
    submitCode({
      postUrl: links.postSubmission,
      code: submittedCode,
      testResults: {
        status: 'unknown',
        tests: [],
      },
      customFunctions: [],
      readonlyRanges: {
        html: htmlReadonlyRanges,
        css: cssReadonlyRanges,
        js: jsReadonlyRanges,
      },
    })

    const result = parseJS(jsView.state.doc.toString())
    switch (result.status) {
      case 'success':
        setLogs([])

        jsCodeRunId.current = (jsCodeRunId.current || 0) + 1
        const fullScript = wrapJSCode(jsCode, jsCodeRunId.current || 0)
        const expectedScript = wrapJSCode(
          exercise.config.expected.js,
          jsCodeRunId.current || 0
        )
        // we'll only run the JS code if:
        // 1. someone clicks the `Run Code` button and
        // 2. there are no parsing errors
        updateIFrame(
          actualIFrameRef,
          {
            script: fullScript,
            html: htmlCode,
            css: cssCode,
          },
          code
        )

        updateIFrame(
          expectedIFrameRef,
          {
            ...exercise.config.expected,
            script: expectedScript,
          },
          code
        )
        updateIFrame(
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
