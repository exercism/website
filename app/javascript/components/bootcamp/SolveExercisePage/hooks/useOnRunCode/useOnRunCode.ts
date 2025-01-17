import { useCallback } from 'react'
import { compile } from '@/interpreter/interpreter'
import useTestStore from '../../store/testStore'
import useEditorStore from '../../store/editorStore'
import useTaskStore from '../../store/taskStore/taskStore'
import { handleSetInspectedTestResult } from '../../TestResultsView/TestResultsButtons'
import generateAndRunTestSuite from '../../test-runner/generateAndRunTestSuite/generateAndRunTestSuite'
import { getAndInitializeExerciseClass } from '../../utils/exerciseMap'
import { showError } from '../../utils/showError'
import { submitCode } from './submitCode'
import { getFirstFailingOrFirstTest } from './getFirstFailingOrFirstTest'
import type { EditorView } from 'codemirror'
import { getCodeMirrorFieldValue } from '../../CodeMirror/getCodeMirrorFieldValue'
import { readOnlyRangesStateField } from '../../CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { scrollToLine } from '../../CodeMirror/scrollToLine'
import useErrorStore from '../../store/errorStore'

export function useOnRunCode({
  links,
  config,
}: Pick<SolveExercisePageProps, 'links'> & {
  config: Config
}) {
  const {
    setTestSuiteResult,
    setInspectedTestResult,
    inspectedTestResult,
    setHasSyntaxError,
  } = useTestStore()

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setHasCodeBeenEdited,
    setUnderlineRange,
  } = useEditorStore()

  const { setHasUnhandledError } = useErrorStore()

  const { markTaskAsCompleted, tasks } = useTaskStore()

  const onRunCode = useCallback(
    (studentCode: string, editorView: EditorView | null) => {
      if (!tasks) {
        console.error('tasks are missing in useRunCode')
        return
      }
      // remove previous views
      document
        .querySelectorAll('.exercise-container')
        .forEach((e) => e.remove())

      // reset on each run
      setHasSyntaxError(false)
      setHasUnhandledError(false)

      const exercise = getAndInitializeExerciseClass(config)

      const context = {
        externalFunctions: exercise?.availableFunctions,
        language: 'JikiScript',
        languageFeatures: config.interpreterOptions,
      }
      // @ts-ignore
      const compiled = compile(studentCode, context)

      const error = compiled.error

      if (error) {
        setHasSyntaxError(true)
        if (!error.location) {
          return
        }
        if (editorView) {
          scrollToLine(editorView, error.location.line)
        }

        showError({
          error,
          setHighlightedLine,
          setHighlightedLineColor,
          setInformationWidgetData,
          setShouldShowInformationWidget,
          setUnderlineRange,
        })

        setTestSuiteResult(null)
        setInspectedTestResult(null)

        return
      }

      const testResults = generateAndRunTestSuite({
        studentCode,
        tasks,
        config,
      })

      setTestSuiteResult(testResults)
      markTaskAsCompleted(testResults)

      const automaticallyInspectedTest = getFirstFailingOrFirstTest(
        testResults,
        inspectedTestResult
      )

      handleSetInspectedTestResult({
        testResult: automaticallyInspectedTest,
        setInspectedTestResult,
        setInformationWidgetData,
      })

      // reset on successful test run
      setHasCodeBeenEdited(false)

      submitCode({
        code: studentCode,
        testResults: {
          status: testResults.status,
          tests: testResults.tests.map((test) => {
            const firstFailingExpect = test.expects.find(
              (e) => e.pass === false
            )
            const actual = firstFailingExpect
              ? firstFailingExpect.testsType === 'io'
                ? firstFailingExpect.actual
                : firstFailingExpect.errorHtml
              : null
            return {
              slug: test.slug,
              status: test.status,
              actual,
            }
          }),
        },
        postUrl: links.postSubmission,
        readonlyRanges: getCodeMirrorFieldValue(
          editorView,
          readOnlyRangesStateField
        ),
      })
    },
    [setTestSuiteResult, tasks, inspectedTestResult]
  )

  return onRunCode
}
