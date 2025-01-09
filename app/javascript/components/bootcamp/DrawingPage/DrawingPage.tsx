import React, { useEffect, useMemo, useState } from 'react'
import { Header, StudentCodeGetter } from './Header/Header'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { useDrawingEditorHandler } from './useDrawingEditorHandler'
import { useLocalStorage } from '@uidotdev/usehooks'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import Scrubber from './Scrubber/Scrubber'
import { debounce } from 'lodash'

export default function DrawingPage({
  drawing,
  code,
  links,
}: DrawingPageProps) {
  const [savingStateLabel, setSavingStateLabel] = useState<string>('')

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'drawing-page-lhs',
  })

  const {
    handleRunCode,
    handleEditorDidMount,
    getStudentCode,
    editorViewRef,
    viewContainerRef,
    animationTimeline,
    frames,
  } = useDrawingEditorHandler({ code, links, drawing })

  const [editorLocalStorageValue, setEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + drawing.uuid,
    { code: code.code, storedAt: code.storedAt }
  )

  const { setDefaultCode, setShouldAutoRunCode } = useEditorStore()

  // Setup hook
  useEffect(() => {
    if (
      editorLocalStorageValue.storedAt &&
      code.storedAt &&
      // if the code on the server is newer than in localstorage, update the storage and load the code from the server
      editorLocalStorageValue.storedAt < code.storedAt
    ) {
      setEditorLocalStorageValue({ code: code.code, storedAt: code.storedAt })
      setDefaultCode(code.code)
    } else {
      // otherwise we are using the code from the storage
      setDefaultCode(editorLocalStorageValue.code)
    }
    setShouldAutoRunCode(true)
  }, [code, setDefaultCode, setEditorLocalStorageValue])

  const patchCodeOnDebounce = useMemo(() => {
    return debounce(() => {
      console.log('saving things')
      setSavingStateLabel('Saving...')
      patchDrawingCode(links, getStudentCode).then(() =>
        setSavingStateLabel('Saved')
      )
    }, 5000)
  }, [setEditorLocalStorageValue])

  return (
    <div id="bootcamp-solve-exercise-page">
      <Header links={links} savingStateLabel={savingStateLabel} />
      <div className="page-body">
        <div style={{ width: LHSWidth }} className="page-body-lhs">
          <ErrorBoundary>
            <CodeMirror
              style={{ height: `100%` }}
              ref={editorViewRef}
              editorDidMount={handleEditorDidMount}
              handleRunCode={handleRunCode}
              setEditorLocalStorageValue={setEditorLocalStorageValue}
              onEditorChangeCallback={patchCodeOnDebounce}
            />
            <Scrubber animationTimeline={animationTimeline} frames={frames} />
          </ErrorBoundary>
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        {/* RHS */}
        <div className="page-body-rhs" style={{ width: RHSWidth }}>
          {/* DRAWING HERE */}
          <div ref={viewContainerRef} id="view-container" />
        </div>
      </div>
    </div>
  )
}

async function patchDrawingCode(
  links: DrawingPageProps['links'],
  getStudentCode: StudentCodeGetter
) {
  const studentCode = getStudentCode()

  const response = await fetch(links.updateCode, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      code: studentCode,
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to save code')
  }

  return response.json()
}
