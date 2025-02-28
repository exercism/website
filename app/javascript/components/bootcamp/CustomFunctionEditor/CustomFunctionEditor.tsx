import React, { useCallback } from 'react'
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
import Scrubber from '../SolveExercisePage/Scrubber/Scrubber'
import SolveExercisePageContextWrapper, {
  SolveExercisePageContextValues,
} from '../SolveExercisePage/SolveExercisePageContextWrapper'
import { EditorView } from 'codemirror'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { CheckCodeButton } from './CheckCodeButton'
import { flushSync } from 'react-dom'
import useCustomFunctionStore from './store/customFunctionsStore'
import { ReadonlyFunctionMyExtension } from '../SolveExercisePage/CodeMirror/extensions/readonly-function-my'
import { useSetupCustomFunctionStore } from './useSetupCustomFunctionsStore'

export type CustomFunction = {
  uuid: string
  name: string
  active: boolean
  description: string
  code: string
  tests: CustomTests
}

export type CustomFunctionEditorProps = {
  customFunction: CustomFunction
  dependsOn: ActiveCustomFunction[]
  availableCustomFunctions: AvailableCustomFunction[]
  links: {
    updateCustomFns: string
    getCustomFns: string
    getCustomFnsForInterpreter: string
    customFnsDashboard: string
  }
}

export default function CustomFunctionEditor({
  customFunction,
  links,
  dependsOn,
  availableCustomFunctions,
}: CustomFunctionEditorProps) {
  const {
    tests,
    testBeingEdited,
    setTestBeingEdited,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
    results,
    setResults,
    inspectedTest,
    setInspectedTest,
    areAllTestsPassing,
  } = useTestManager(customFunction)

  const {
    name,
    setName,
    description,
    setDescription,
    isActivated,
    setIsActivated,
  } = useFunctionDetailsManager(customFunction)

  const { editorViewRef, handleEditorDidMount, handleRunCode, arity } =
    useCustomFunctionEditorHandler({
      tests,
      setResults,
      setInspectedTest,
      functionName: name,
    })

  const { updateLocalStorageValueOnDebounce } =
    useManageEditorDefaultValue(customFunction)

  useSetupCustomFunctionStore({
    dependsOn,
    availableCustomFunctions,
    customFunction,
  })

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })

  const handleSetFnName = useCallback((view: EditorView) => {
    const docText = view.state.doc.toString()
    const functionName = extractFunctionName(docText)
    setName(functionName ?? '')
  }, [])

  const { customFunctionsForInterpreter } = useCustomFunctionStore()
  const handlePatchChanges = useCallback(() => {
    patchCustomFunction({
      url: links.updateCustomFns,
      name: name.replace('my#', ''),
      fn_name: name,
      active: isActivated && areAllTestsPassing,
      code: editorViewRef.current?.state.doc.toString() ?? '',
      description,
      fn_arity: arity || 0,
      tests,
      dependsOn: customFunctionsForInterpreter.map((cfn) => cfn.name),
    })
  }, [
    name,
    isActivated,
    areAllTestsPassing,
    editorViewRef,
    tests,
    description,
    arity,
    customFunctionsForInterpreter,
  ])

  const { cleanUpEditorStore } = useEditorStore()
  const handleCheckCode = useCallback(() => {
    flushSync(cleanUpEditorStore)
    handleRunCode(tests, customFunctionsForInterpreter)
  }, [tests, customFunctionsForInterpreter])

  return (
    <SolveExercisePageContextWrapper
      value={
        {
          editorView: editorViewRef.current,
          isSpotlightActive: false,
          links,
        } as SolveExercisePageContextValues
      }
    >
      <div id="bootcamp-custom-function-editor-page">
        <Header
          handleSaveChanges={handlePatchChanges}
          someTestsAreFailing={!areAllTestsPassing}
        />
        <div className="page-body">
          <div style={{ width: LHSWidth }} className="page-body-lhs">
            <ErrorBoundary>
              <CodeMirror
                style={{ height: `100%` }}
                ref={editorViewRef}
                editorDidMount={handleEditorDidMount}
                handleRunCode={() =>
                  handleRunCode(tests, customFunctionsForInterpreter)
                }
                onEditorChangeCallback={(view) => {
                  handleSetFnName(view)
                  updateLocalStorageValueOnDebounce(view.state.doc.toString())
                }}
                extensions={[ReadonlyFunctionMyExtension]}
              />
            </ErrorBoundary>

            <div className="page-lhs-bottom">
              <Scrubber
                animationTimeline={null}
                frames={
                  results && results[inspectedTest]
                    ? results[inspectedTest].frames
                    : []
                }
              />
              <CheckCodeButton handleRunCode={handleCheckCode} />
            </div>
          </div>

          <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
          {/* RHS */}
          <div className="page-body-rhs p-8" style={{ width: RHSWidth }}>
            <CustomFunctionDetails
              name={name}
              isActivated={isActivated && areAllTestsPassing}
              setIsActivated={setIsActivated}
              areAllTestsPassing={areAllTestsPassing}
              description={description}
              setDescription={setDescription}
            />
            <CustomFunctionTests
              tests={tests}
              fnName={name}
              results={results}
              inspectedTest={inspectedTest}
              setInspectedTest={setInspectedTest}
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
    </SolveExercisePageContextWrapper>
  )
}

function extractFunctionName(code: string): string | null {
  const match = code.match(/function\s+(my#[a-zA-Z_$][a-zA-Z0-9_$]*)/)
  return match ? match[1] : null
}

export async function patchCustomFunction({
  url,
  name,
  active,
  description,
  code,
  tests,
  fn_name,
  fn_arity,
  dependsOn,
}: {
  url: string
  name: string
  active: boolean
  description: string
  code: string
  tests: CustomTests
  fn_name: string
  fn_arity: number
  dependsOn: string[]
}) {
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      custom_function: {
        name,
        active,
        description,
        code,
        tests,
        fn_name,
        fn_arity,
        depends_on: dependsOn,
      },
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
