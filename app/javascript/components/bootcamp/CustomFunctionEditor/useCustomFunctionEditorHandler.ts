import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../JikiscriptExercisePage/CodeMirror/CodeMirror'
import {
  evaluateFunction,
  EvaluationContext,
  interpret,
} from '@/interpreter/interpreter'
import useEditorStore from '../JikiscriptExercisePage/store/editorStore'
import { showError } from '../JikiscriptExercisePage/utils/showError'
import { StdlibFunctionsForLibrary } from '@/interpreter/stdlib'
import { buildAnimationTimeline } from '../JikiscriptExercisePage/test-runner/generateAndRunTestSuite/execTest'
import { framesSucceeded } from '@/interpreter/frames'
import { updateUnfoldableFunctions } from '../JikiscriptExercisePage/CodeMirror/unfoldableFunctionNames'
import { CustomFunction } from './CustomFunctionEditor'
import customFunctionEditorStore from './store/customFunctionEditorStore'
import customFunctionsStore from './store/customFunctionsStore'
import { FunctionStatement } from '@/interpreter/statement'

export function useCustomFunctionEditorHandler({
  customFunctionDataFromServer,
}: {
  customFunctionDataFromServer: CustomFunction
}) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const {
    customFunctionArity: arity,
    setCustomFunctionArity: setArity,
    setResults,
    clearInspectedTest,
    setInspectedTest,
    setSyntaxErrorInTest,
  } = customFunctionEditorStore()

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler

    setupCustomFunctionEditor(
      editorViewRef.current,
      customFunctionDataFromServer
    )
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
    const { tests, customFunctionName: functionName } =
      customFunctionEditorStore.getState()

    if (!tests || tests.length === 0) {
      return
    }

    const customFunctions =
      customFunctionsStore.getState().customFunctionsForInterpreter

    setHasCodeBeenEdited(false)

    if (editorHandler.current) {
      const context: EvaluationContext = {
        languageFeatures: { customFunctionDefinitionMode: true },
        customFunctions: Object.values(customFunctions),
        externalFunctions: StdlibFunctionsForLibrary,
      }
      const value = editorHandler.current.getValue()
      setLatestValueSnapshot(value)

      const evaluated = interpret(value, context)
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

      const fnStatement = evaluated.meta.statements[0] as FunctionStatement
      setArity(fnStatement.parameters.length)

      const results = {}
      let errorOccurred: boolean = false
      for (const test of tests) {
        const args = test.args
        const safe_eval = eval
        let safeArgs
        try {
          safeArgs = safe_eval(`[${args}]`)
        } catch (e) {
          setSyntaxErrorInTest({
            message: `<div><div class="mb-6 font-semibold leading-140">Oh no! Jiki couldn't understand this code:</div>
                <pre class="bg-white"><code class="lang-jikiscript hljs">${args}</code></pre>
              </div>`,
            testUuid: test.uuid,
          })
          errorOccurred = true
          break
        }

        const fnEvaluationResult = evaluateFunction(
          value,
          context,
          functionName,
          ...safeArgs
        )

        let expected

        try {
          expected = safe_eval(`[${test.expected}]`)[0]
        } catch (e) {
          setSyntaxErrorInTest({
            message: `<div><div class="mb-6 font-semibold leading-140">Oh no! Jiki couldn't understand your expected value:</div>
                <pre class="bg-white"><code class="lang-jikiscript hljs">${test.expected}</code></pre>
              </div>`,
            testUuid: test.uuid,
          })
          errorOccurred = true
          break
        }

        const animationTimeline = buildAnimationTimeline(
          undefined,
          fnEvaluationResult.frames
        )

        // Don't play out the animation if there are errors
        // The scrubber will automatically handle jumping to
        // the first error.
        //
        // Note: If you ever change this, check your new code with
        // a runtime error on the first line.
        if (framesSucceeded(fnEvaluationResult.frames)) {
          animationTimeline.play()
        }

        const result = {
          actual: JSON.stringify(fnEvaluationResult.value),
          frames: fnEvaluationResult.frames,
          animationTimeline,
          pass:
            JSON.stringify(fnEvaluationResult.value) ===
            JSON.stringify(expected),
        }

        results[test.uuid] = result
      }

      if (errorOccurred) {
        return
      }

      setResults(results)

      // Clear the selected test
      // then set the new one.
      clearInspectedTest()
      // Autoselect the first test as inspected
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

function setupCustomFunctionEditor(
  editorView: EditorView | null,
  customFunction: CustomFunction
) {
  if (!editorView) return
  updateUnfoldableFunctions(editorView, [customFunction.name])

  const { code } = customFunction

  if (code) {
    editorView.dispatch({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: code,
      },
    })
  }
}
