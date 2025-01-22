import React, { useMemo, useState } from 'react'
import { Header, StudentCodeGetter } from './Header/Header'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { useDrawingEditorHandler } from './useDrawingEditorHandler'
import { useLocalStorage } from '@uidotdev/usehooks'
import Scrubber from '../SolveExercisePage/Scrubber/Scrubber'
import { debounce } from 'lodash'
import { useSetupDrawingPage } from './useSetupDrawingPage'
import SolveExercisePageContextWrapper from '../SolveExercisePage/SolveExercisePageContextWrapper'

export default function DrawingPage({
  drawing,
  code,
  links,
  backgrounds,
}: DrawingPageProps) {
  const [savingStateLabel, setSavingStateLabel] = useState<string>('')

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })
  const {
    handleRunCode,
    handleEditorDidMount,
    getStudentCode,
    editorViewRef,
    viewContainerRef,
    animationTimeline,
    frames,
    setBackgroundImage,
  } = useDrawingEditorHandler()

  const [editorLocalStorageValue, setEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + drawing.uuid,
    { code: code.code, storedAt: code.storedAt }
  )

  useSetupDrawingPage({
    code,
    editorLocalStorageValue,
    setEditorLocalStorageValue,
  })

  const patchCodeOnDebounce = useMemo(() => {
    return debounce(() => {
      setSavingStateLabel('Saving...')
      patchDrawingCode(links, getStudentCode).then(() =>
        setSavingStateLabel('Saved')
      )
    }, 5000)
  }, [setEditorLocalStorageValue])

  return (
    <SolveExercisePageContextWrapper
      value={{
        editorView: editorViewRef.current,
      }}
    >
      <div id="bootcamp-solve-exercise-page">
        <Header
          links={links}
          backgrounds={backgrounds}
          savingStateLabel={savingStateLabel}
          drawing={drawing}
          setBackgroundImage={setBackgroundImage}
        />
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
            <div ref={viewContainerRef} id="view-container" />
          </div>
        </div>
      </div>
    </SolveExercisePageContextWrapper>
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
