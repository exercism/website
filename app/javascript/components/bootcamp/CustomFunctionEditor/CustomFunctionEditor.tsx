import React from 'react'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useCustomFunctionEditorHandler } from './useCustomFunctionEditorHandler'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { useTestManager } from './useTestManager'
import { CustomFunctionTests } from './CustomFunctionTests'

export default function CustomFunctionEditor({ data }) {
  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'drawing-page-lhs',
  })

  const { editorViewRef, handleEditorDidMount, handleRunCode } =
    useCustomFunctionEditorHandler()

  const {
    tests,
    testBeingEdited,
    setTestBeingEdited,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
  } = useTestManager()

  return (
    <div id="bootcamp-solve-exercise-page">
      <Header links={data.links} />
      <div className="page-body">
        <div style={{ width: LHSWidth }} className="page-body-lhs">
          <ErrorBoundary>
            <CodeMirror
              style={{ height: `100%` }}
              ref={editorViewRef}
              editorDidMount={handleEditorDidMount}
              handleRunCode={handleRunCode}
            />
          </ErrorBoundary>

          <div className="page-lhs-bottom">
            <button className="scenarios-button flex btn-primary btn-s">
              Check code
            </button>
          </div>
        </div>

        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        {/* RHS */}
        <div className="page-body-rhs p-8" style={{ width: RHSWidth }}>
          <CustomFunctionDetails />
          <CustomFunctionTests
            tests={tests}
            testBeingEdited={testBeingEdited}
            setTestBeingEdited={setTestBeingEdited}
            handleDeleteTest={handleDeleteTest}
            handleUpdateTest={handleUpdateTest}
            handleCancelEditing={handleCancelEditing}
            handleAddNewTest={handleAddNewTest}
          />
        </div>
      </div>
    </div>
  )
}

const labelClassName = 'font-mono font-semibold mb-4'
function CustomFunctionDetails() {
  return (
    <div className="flex flex-col mb-24">
      <label className={labelClassName} htmlFor="fn-name">
        Function name{' '}
      </label>
      <input className="mb-12" name="fn-name" type="text" />

      <label className={labelClassName} htmlFor="description">
        Description{' '}
      </label>
      <textarea name="description" id=""></textarea>
    </div>
  )
}
