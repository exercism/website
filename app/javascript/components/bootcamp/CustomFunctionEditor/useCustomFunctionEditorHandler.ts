import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import type { Frame } from '@/interpreter/frames'
import { CustomTests, Results } from './useTestManager'

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

  const [frames, setFrames] = useState<Frame[]>([])

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    // run code on mount
    handleRunCode()
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

  const handleRunCode = () => {
    setHasCodeBeenEdited(false)
    if (editorHandler.current) {
      const value = editorHandler.current.getValue()
      setLatestValueSnapshot(value)
      // value is studentCode

      const evaluated = interpret(value)
      tests.forEach((test) => {
        const params = test.codeRun

        const parsedParams = formatParams(params.split(','))
        const fnEvaluationResult = evaluateFunction(
          value,
          {},
          functionName,
          ...parsedParams
        )
        setResults((a) => ({
          ...a,
          [test.uuid]: {
            actual: JSON.stringify(fnEvaluationResult.value),
            frames: fnEvaluationResult.frames,
          },
        }))
        setInspectedTest(test.uuid)
      })

      const { frames } = evaluated
      setFrames(frames)

      if (evaluated.error) {
        showError({
          error: evaluated.error,
          setHighlightedLine,
          setHighlightedLineColor,
          setInformationWidgetData,
          setShouldShowInformationWidget,
          setUnderlineRange,
        })

        setFrames([])
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
    frames,
  }
}

const formatParams = (params: string[]): any[] => {
  return params.map((param) => {
    const trimmed = param.trim()
    if (/^".*"$/.test(trimmed)) {
      // remove " "
      return trimmed.slice(1, -1)
    }
    const num = Number(trimmed)
    return isNaN(num) ? trimmed : num
  })
}
