import React, { useEffect } from 'react'
import { Header } from '../SolveExercisePage/Header/Header'
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

export default function DrawingPage({
  drawing,
  code,
  links,
}: DrawingPageProps) {
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
  }, [])

  return (
    <div id="bootcamp-solve-exercise-page">
      <Header />
      <div className="page-body">
        <div style={{ width: LHSWidth }} className="page-body-lhs">
          <ErrorBoundary>
            <CodeMirror
              style={{ height: `100%` }}
              ref={editorViewRef}
              editorDidMount={handleEditorDidMount}
              handleRunCode={handleRunCode}
              setEditorLocalStorageValue={setEditorLocalStorageValue}
            />
            <Scrubber animationTimeline={animationTimeline} frames={frames} />
          </ErrorBoundary>
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        {/* RHS */}
        <div className="page-body-rhs" style={{ width: RHSWidth }}>
          {/* DRAWING HERE */}
          <button onClick={handleRunCode}>run code</button>
          <div ref={viewContainerRef} id="view-container" />
        </div>
      </div>
    </div>
  )
}
