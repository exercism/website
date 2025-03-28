import React, { createContext, useCallback, useEffect, useMemo } from 'react'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { CodeMirror } from '../JikiscriptExercisePage/CodeMirror/CodeMirror'
import { useCustomFunctionEditorHandler } from './useCustomFunctionEditorHandler'
import {
  Resizer,
  useResizablePanels,
} from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { CustomTests } from './useTestManager'
import { CustomFunctionTests } from './CustomFunctionTests'
import { CustomFunctionDetails } from './CustomFunctionDetails'
import Scrubber from '../JikiscriptExercisePage/Scrubber/Scrubber'
import JikiscriptExercisePageContextWrapper, {
  JikiscriptExercisePageContextValues,
} from '../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import useEditorStore from '../JikiscriptExercisePage/store/editorStore'
import { CheckCodeButton } from './CheckCodeButton'
import { flushSync } from 'react-dom'
import useCustomFunctionStore from './store/customFunctionsStore'
import { ReadonlyFunctionMyExtension } from '../JikiscriptExercisePage/CodeMirror/extensions/readonly-function-my'
import { useSetupCustomFunctionStore } from './useSetupCustomFunctionsStore'
import customFunctionEditorStore, {
  CustomFunctionEditorStore,
} from './store/customFunctionEditorStore'
import { Toaster } from 'react-hot-toast'
import useWarnOnUnsavedChanges from './Header/useWarnOnUnsavedChanges'
import { DeleteFunctionButton } from './DeleteFunctionButton'

export type CustomFunction = {
  uuid: string
  name: string
  active: boolean
  description: string
  predefined: boolean
  code: string
  tests: CustomTests
}

export type CustomFunctionEditorProps = {
  customFunction: CustomFunction
  customFunctions: CustomFunctionsFromServer
  links: {
    updateCustomFns: string
    customFnsDashboard: string
    deleteCustomFn: string
  }
}

export const CustomFunctionEditorStoreContext = createContext<{
  customFunctionEditorStore: CustomFunctionEditorStore
}>({ customFunctionEditorStore: {} as CustomFunctionEditorStore })

export const CustomFunctionContext = createContext<CustomFunction | null>(null)

export default function CustomFunctionEditor({
  customFunction,
  customFunctions,
  links,
}: CustomFunctionEditorProps) {
  const { editorViewRef, handleEditorDidMount, handleRunCode } =
    useCustomFunctionEditorHandler({
      customFunctionDataFromServer: customFunction,
    })

  useSetupCustomFunctionStore({
    customFunction,
    customFunctions,
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
    setHasUnsavedChanges,
    inspectedFrames,
    inspectedTest,
    initializeStore,
    hasUnsavedChanges,
    clearSyntaxErrorInTest,
    results,
  } = customFunctionEditorStore()

  useEffect(() => {
    initializeStore(customFunction)
    setTimeout(() => setHasUnsavedChanges(false), 100)
  }, [])

  useWarnOnUnsavedChanges(hasUnsavedChanges)

  const { getSelectedCustomFunctions } = useCustomFunctionStore()

  const { cleanUpEditorStore, setDefaultCode } = useEditorStore()

  useEffect(() => {
    setDefaultCode(customFunction.code)
  }, [])

  const handleCheckCode = useCallback(() => {
    flushSync(cleanUpEditorStore)
    flushSync(clearSyntaxErrorInTest)
    handleRunCode()
  }, [])

  const inspectedTestIdx = useMemo(
    () => tests.findIndex((test) => test.uuid === inspectedTest),
    [inspectedTest, tests]
  )

  const readOnlyDocumentFragment = useMemo(() => {
    const { code, predefined } = customFunction

    const fullName = new RegExp(/function my#\w+/)
    const fnStub = new RegExp(/function my#/)

    const match = code.match(predefined ? fullName : fnStub)
    const readonlyBit = match ? match[0] : null

    return ReadonlyFunctionMyExtension(readonlyBit?.length || 0)
  }, [customFunction])

  return (
    <JikiscriptExercisePageContextWrapper
      value={
        {
          editorView: editorViewRef.current,
          isSpotlightActive: false,
          links,
        } as JikiscriptExercisePageContextValues
      }
    >
      <CustomFunctionContext.Provider value={customFunction}>
        <div id="bootcamp-custom-function-editor-page">
          <Header
            handleSaveChanges={() =>
              handlePatchCustomFunction({
                code: editorViewRef.current?.state.doc.toString() ?? '',
                dependsOn: getSelectedCustomFunctions(),
                url: links.updateCustomFns,
              })
            }
          />
          <div className="page-body">
            <div style={{ width: LHSWidth }} className="page-body-lhs">
              <ErrorBoundary>
                <CodeMirror
                  style={{ height: `100%` }}
                  ref={editorViewRef}
                  editorDidMount={handleEditorDidMount}
                  handleRunCode={() => handleRunCode()}
                  onEditorChangeCallback={(view) => {
                    setHasUnsavedChanges(true)
                    handleSetCustomFunctionName(view)

                    const { areAllTestsPassing } =
                      customFunctionEditorStore.getState()
                    if (areAllTestsPassing) {
                      clearResults()
                    }
                  }}
                  extensions={[readOnlyDocumentFragment]}
                />
              </ErrorBoundary>

              <div className="page-lhs-bottom flex items-center gap-8 bg-white">
                <CheckCodeButton handleRunCode={handleCheckCode} />
                <div className="flex-grow">
                  {results &&
                    results[inspectedTest] &&
                    results[inspectedTest].animationTimeline && (
                      <Scrubber
                        animationTimeline={
                          results[inspectedTest].animationTimeline
                        }
                        frames={inspectedFrames}
                        context={`Test ${inspectedTestIdx + 1}`}
                      />
                    )}
                </div>
              </div>
            </div>

            <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
            {/* RHS */}
            <div
              className="page-body-rhs py-16 px-16"
              style={{ width: RHSWidth }}
            >
              <CustomFunctionDetails />
              <CustomFunctionTests />
            </div>
          </div>
        </div>
        <Toaster />
      </CustomFunctionContext.Provider>
    </JikiscriptExercisePageContextWrapper>
  )
}
