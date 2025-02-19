import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import type { Frame } from '@/interpreter/frames'
import { CustomTests } from './useTestManager'

export function useCustomFunctionEditorHandler({
  tests,
  setActuals,
}: {
  tests: CustomTests
  setActuals: React.Dispatch<React.SetStateAction<Record<string, string>>>
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
        const [fnName, params] = test.codeRun.split(/[()]/)

        const parsedParams = formatParams(params.split(','))
        console.log('parsedParams', parsedParams)
        const fnEvaluationResult = evaluateFunction(
          value,
          {},
          fnName,
          ...parsedParams
        )
        setActuals((a) => ({
          ...a,
          [test.codeRun]: JSON.stringify(fnEvaluationResult.value),
        }))
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
        // return
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
      // If wrapped in double quotes, return as string (remove quotes)
      return trimmed.slice(1, -1)
    }
    const num = Number(trimmed)
    return isNaN(num) ? trimmed : num
  })
}
