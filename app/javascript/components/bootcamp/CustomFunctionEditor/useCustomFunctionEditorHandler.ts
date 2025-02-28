import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import {
  CustomFunction,
  evaluateFunction,
  interpret,
} from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import { CustomTests } from './useTestManager'
import useCustomFunctionStore from './store/customFunctionsStore'
import { CustomFunctionEditorStore } from './store/customFunctionEditorStore'

export function useCustomFunctionEditorHandler({
  customFunctionEditorStore,
}: {
  customFunctionEditorStore: CustomFunctionEditorStore
}) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const { customFunctionsForInterpreter } = useCustomFunctionStore()

  const {
    customFunctionArity: arity,
    setCustomFunctionArity: setArity,
    tests,
    customFunctionName: functionName,
    setResults,
    setInspectedTest,
  } = customFunctionEditorStore()

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    // run code on mount
    handleRunCode(tests, customFunctionsForInterpreter)
  }

  const getStudentCode = () => {
    if (editorViewRef.current) {
      return editorViewRef.current.state.doc.toString()
    }
  }

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
    setHasCodeBeenEdited,
  } = useEditorStore()

  // TODO: clean up errors on handle run code
  const handleRunCode = (
    tests: CustomTests,
    customFunctions: CustomFunction[] = []
  ) => {
    if (!tests || tests.length === 0) {
      return
    }

    setHasCodeBeenEdited(false)

    if (editorHandler.current) {
      const value = editorHandler.current.getValue()
      setLatestValueSnapshot(value)

      const evaluated = interpret(value)
      if (evaluated.error) {
        showError({
          error: evaluated.error,
          editorView: editorViewRef.current,
          setHighlightedLine,
          setHighlightedLineColor,
          setInformationWidgetData,
          setShouldShowInformationWidget,
          setUnderlineRange,
        })
        return
      }

      const results = {}
      tests.forEach((test) => {
        const params = test.params
        const safe_eval = eval
        const args = safe_eval(`[${params}]`)
        setArity(args.length)

        const fnEvaluationResult = evaluateFunction(
          value,
          {
            languageFeatures: { customFunctionDefinitionMode: true },
            customFunctions,
          },
          functionName,
          ...args
        )

        const result = {
          actual: JSON.stringify(fnEvaluationResult.value),
          frames: fnEvaluationResult.frames,
          pass: JSON.stringify(fnEvaluationResult.value) === test.expected,
        }

        results[test.uuid] = result
      })

      setResults(results)

      // autoselect the first test as inspected
      setInspectedTest(tests[0].uuid)
    }
  }

  return {
    handleEditorDidMount,
    handleRunCode,
    getStudentCode,
    editorHandler,
    latestValueSnapshot,
    editorViewRef,
    arity,
  }
}
