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

export function useOnRunCode({
  links,
  config,
  editorView,
}: Pick<SolveExercisePageProps, 'links'> & {
  config: Config
  editorView: EditorView | null
}) {
  const {
    setTestSuiteResult,
    setInspectedTestResult,
    inspectedTestResult,
    testSuiteResult,
  } = useTestStore()

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setHasCodeBeenEdited,
    setUnderlineRange,
  } = useEditorStore()

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
        if (!error.location) {
          return
        }
        if (editorView) {
          const absoluteLocationBegin = error.location.absolute.begin
          const top = editorView.coordsAtPos(
            editorView.lineBlockAt(absoluteLocationBegin).top
          )?.top
          if (top) {
            editorView.scrollDOM.scrollTo({
              top,
              behavior: 'smooth',
            })
          }
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
