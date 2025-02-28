import React, { createContext, useCallback, useEffect, useMemo } from 'react'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useCustomFunctionEditorHandler } from './useCustomFunctionEditorHandler'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { CustomTests } from './useTestManager'
import { CustomFunctionTests } from './CustomFunctionTests'
import { CustomFunctionDetails } from './CustomFunctionDetails'
import { useManageEditorDefaultValue } from './useManageEditorDefaultValue'
import Scrubber from '../SolveExercisePage/Scrubber/Scrubber'
import SolveExercisePageContextWrapper, {
  SolveExercisePageContextValues,
} from '../SolveExercisePage/SolveExercisePageContextWrapper'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { CheckCodeButton } from './CheckCodeButton'
import { flushSync } from 'react-dom'
import useCustomFunctionStore from './store/customFunctionsStore'
import { ReadonlyFunctionMyExtension } from '../SolveExercisePage/CodeMirror/extensions/readonly-function-my'
import { useSetupCustomFunctionStore } from './useSetupCustomFunctionsStore'
import {
  createCustomFunctionEditorStore,
  CustomFunctionEditorStore,
} from './store/customFunctionEditorStore'
import { Toaster } from 'react-hot-toast'

export type CustomFunction = {
  uuid: string
  name: string
  fnName: string
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

export const CustomFunctionEditorStoreContext = createContext<{
  customFunctionEditorStore: CustomFunctionEditorStore
}>({ customFunctionEditorStore: {} as CustomFunctionEditorStore })

export default function CustomFunctionEditor({
  customFunction,
  links,
  dependsOn,
  availableCustomFunctions,
}: CustomFunctionEditorProps) {
  const customFunctionEditorStore = useMemo(
    () => createCustomFunctionEditorStore(customFunction.uuid),
    [customFunction.uuid]
  )

  const { editorViewRef, handleEditorDidMount, handleRunCode } =
    useCustomFunctionEditorHandler({ customFunctionEditorStore })

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

  const {
    handleSetCustomFunctionName,
    handlePatchCustomFunction,
    tests,
    clearResults,
    areAllTestsPassing,
    inspectedFrames,
    inspectedTest,
    initializeStore,
  } = customFunctionEditorStore()

  useEffect(() => {
    initializeStore(customFunction)
  }, [])

  const { customFunctionsForInterpreter } = useCustomFunctionStore()

  const { cleanUpEditorStore } = useEditorStore()
  const handleCheckCode = useCallback(() => {
    flushSync(cleanUpEditorStore)
    handleRunCode(tests, customFunctionsForInterpreter)
  }, [tests, customFunctionsForInterpreter])

  const inspectedTestIdx = tests.findIndex(
    (test) => test.uuid === inspectedTest
  )

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
      <CustomFunctionEditorStoreContext.Provider
        value={{ customFunctionEditorStore }}
      >
        <div id="bootcamp-custom-function-editor-page">
          <Header
            handleSaveChanges={() =>
              handlePatchCustomFunction({
                code: editorViewRef.current?.state.doc.toString() ?? '',
                dependsOn: customFunctionsForInterpreter.map((cfn) => cfn.name),
                url: links.updateCustomFns,
              })
            }
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
                    handleSetCustomFunctionName(view)
                    if (areAllTestsPassing) {
                      clearResults()
                    }
                    updateLocalStorageValueOnDebounce(view.state.doc.toString())
                  }}
                  extensions={[ReadonlyFunctionMyExtension]}
                />
              </ErrorBoundary>

              <div className="page-lhs-bottom">
                <Scrubber
                  animationTimeline={null}
                  frames={inspectedFrames}
                  context={`Test ${inspectedTestIdx + 1}`}
                />
                <CheckCodeButton handleRunCode={handleCheckCode} />
              </div>
            </div>

            <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
            {/* RHS */}
            <div className="page-body-rhs p-8" style={{ width: RHSWidth }}>
              <CustomFunctionDetails />
              <CustomFunctionTests />
            </div>
          </div>
        </div>
        <Toaster />
      </CustomFunctionEditorStoreContext.Provider>
    </SolveExercisePageContextWrapper>
  )
}
