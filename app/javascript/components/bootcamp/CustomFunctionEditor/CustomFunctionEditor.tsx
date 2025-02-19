import React from 'react'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useCustomFunctionEditorHandler } from './useCustomFunctionEditorHandler'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { CustomTests, useTestManager } from './useTestManager'
import { CustomFunctionTests } from './CustomFunctionTests'
import { useFunctionDetailsManager } from './useFunctionDetailsManager'
import { CustomFunctionDetails } from './CustomFunctionDetails'
import { useManageEditorDefaultValue } from './useManageEditorDefaultValue'

export type CustomFunction = {
  uuid: string
  name: string
  description: string
  code: string
  tests: CustomTests
}

export type CustomFunctionEditorProps = {
  customFunction: CustomFunction
  links: {
    update: string
  }
}

export default function CustomFunctionEditor({
  customFunction,
  links,
}: CustomFunctionEditorProps) {
  const {
    tests,
    testBeingEdited,
    setTestBeingEdited,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
    actuals,
    setActuals,
  } = useTestManager(customFunction)

  const { name, setName, description, setDescription } =
    useFunctionDetailsManager(customFunction)

  const { editorViewRef, handleEditorDidMount, handleRunCode } =
    useCustomFunctionEditorHandler({ tests, setActuals })

  const { updateLocalStorageValueOnDebounce } =
    useManageEditorDefaultValue(customFunction)

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'drawing-page-lhs',
  })

  return (
    <div id="bootcamp-solve-exercise-page">
      <Header links={links} />
      <div className="page-body">
        <div style={{ width: LHSWidth }} className="page-body-lhs">
          <ErrorBoundary>
            <CodeMirror
              style={{ height: `100%` }}
              ref={editorViewRef}
              editorDidMount={handleEditorDidMount}
              handleRunCode={handleRunCode}
              onEditorChangeCallback={(view) =>
                updateLocalStorageValueOnDebounce(view.state.doc.toString())
              }
            />
          </ErrorBoundary>

          <div className="page-lhs-bottom">
            <button
              onClick={handleRunCode}
              className="scenarios-button flex btn-primary btn-s"
            >
              Check code
            </button>
          </div>
        </div>

        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        {/* RHS */}
        <div className="page-body-rhs p-8" style={{ width: RHSWidth }}>
          <CustomFunctionDetails
            name={name}
            setName={setName}
            description={description}
            setDescription={setDescription}
          />
          <CustomFunctionTests
            tests={tests}
            actuals={actuals}
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
