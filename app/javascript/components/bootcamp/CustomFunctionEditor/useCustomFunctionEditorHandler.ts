import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import { CustomTests, Results } from './useTestManager'
import useCustomFunctionStore from './store/customFunctionsStore'

export function useCustomFunctionEditorHandler({
  tests,
  setResults,
  functionName,
  setInspectedTest,
}: {
  tests: CustomTests
  setResults: React.Dispatch<React.SetStateAction<Results>>
  functionName: string
  setInspectedTest: React.Dispatch<React.SetStateAction<string>>
}) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const [arity, setArity] = useState<number>()

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    // run code on mount
    handleRunCode(tests)
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

  const { customFunctionsForInterpreter } = useCustomFunctionStore()

  // TODO: clean up errors on handle run code
  const handleRunCode = (tests: CustomTests) => {
    if (!tests || tests.length === 0) {
      return
    }
    setHasCodeBeenEdited(false)
    if (editorHandler.current) {
      const value = editorHandler.current.getValue()
      setLatestValueSnapshot(value)

      const evaluated = interpret(value)

      const customFunctions = customFunctionsForInterpreter.map((cfn) => {
        return {
          name: cfn.name,
          arity: cfn.arity,
          code: cfn.code,
        }
      })

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

        console.log('fn eval result', fnEvaluationResult)

        setResults((a) => ({
          ...a,
          [test.uuid]: {
            actual: JSON.stringify(fnEvaluationResult.value),
            frames: fnEvaluationResult.frames,
            pass: JSON.stringify(fnEvaluationResult.value) === test.expected,
          },
        }))
      })

      // autoselect the first test as inspected
      setInspectedTest(tests[0].uuid)

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
      }
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
