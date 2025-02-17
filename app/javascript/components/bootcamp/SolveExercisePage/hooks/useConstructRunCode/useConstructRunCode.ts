import { useCallback } from 'react'
import { CompilationError, compile } from '@/interpreter/interpreter'
import useTestStore from '../../store/testStore'
import useEditorStore from '../../store/editorStore'
import useTaskStore from '../../store/taskStore/taskStore'
import { handleSetInspectedTestResult } from '../../TestResultsView/TestResultsButtons'
import generateAndRunTestSuite from '../../test-runner/generateAndRunTestSuite/generateAndRunTestSuite'
import { showError } from '../../utils/showError'
import { submitCode } from './submitCode'
import { getFirstFailingOrLastTest } from './getFirstFailingOrLastTest'
import type { EditorView } from 'codemirror'
import { getCodeMirrorFieldValue } from '../../CodeMirror/getCodeMirrorFieldValue'
import { readOnlyRangesStateField } from '../../CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { scrollToLine } from '../../CodeMirror/scrollToLine'
import { cleanUpEditor } from '../../CodeMirror/extensions/clean-up-editor'
import useAnimationTimelineStore from '../../store/animationTimelineStore'

export function useConstructRunCode({
  links,
  config,
}: Pick<SolveExercisePageProps, 'links'> & {
  config: Config
}) {
  const {
    setTestSuiteResult,
    setBonusTestSuiteResult,
    setInspectedTestResult,
    inspectedTestResult,
    setHasSyntaxError,
  } = useTestStore()

  const { setShouldAutoplayAnimation } = useAnimationTimelineStore()

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setHasCodeBeenEdited,
    setUnderlineRange,
  } = useEditorStore()

  const {
    markTaskAsCompleted,
    tasks,
    bonusTasks,
    setShouldShowBonusTasks,
    shouldShowBonusTasks,
  } = useTaskStore()

  const handleCompilationError = (error, editorView) => {
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
  }

  /**
   * This function is used to run the code in the editor
   */
  const runCode = useCallback(
    (studentCode: string, editorView: EditorView | null) => {
      if (!tasks) {
        console.error('tasks are missing in useRunCode')
        return
      }

      // reset on each run
      cleanUpEditor(editorView)

      // remove previous views
      document
        .querySelectorAll('.exercise-container')
        .forEach((e) => e.remove())

      // @ts-ignore
      const compiled = compile(studentCode, {
        languageFeatures: config.interpreterOptions,
      })

      const error = compiled.error as CompilationError

      if (error) {
        handleCompilationError(error, editorView)
        return
      }

      let testResults
      try {
        testResults = generateAndRunTestSuite({
          studentCode,
          tasks,
          config,
        })
      } catch (error) {
        const compError = error as CompilationError
        console.log(compError)
        if (
          compError.hasOwnProperty('type') &&
          compError.type == 'CompilationError'
        ) {
          handleCompilationError(compError.error, editorView)
          return
        }
      }

      const bonusTestResults = generateAndRunTestSuite({
        studentCode,
        tasks: bonusTasks ?? [],
        config,
      })

      setTestSuiteResult(testResults)
      setBonusTestSuiteResult(bonusTestResults)

      markTaskAsCompleted(testResults)

      const automaticallyInspectedTest = getFirstFailingOrLastTest(
        testResults,
        bonusTestResults,
        inspectedTestResult,
        shouldShowBonusTasks
      )

      if (automaticallyInspectedTest.animationTimeline) {
        // means it should autoplay animation on scenario change
        setShouldAutoplayAnimation(true)
        automaticallyInspectedTest.animationTimeline.play()
      }

      handleSetInspectedTestResult({
        testResult: automaticallyInspectedTest,
        setInspectedTestResult,
        setInformationWidgetData,
      })

      // reset on successful test run
      setHasCodeBeenEdited(false)

      const areBasicTestsPassing = testResults.status === 'pass'
      const areBonusTestsPassing = bonusTestResults.status === 'pass'
      const submissionStatus =
        areBasicTestsPassing && areBonusTestsPassing
          ? 'pass_bonus'
          : testResults.status

      if (submissionStatus === 'pass_bonus') {
        setShouldShowBonusTasks(true)
      }

      submitCode({
        code: studentCode,
        testResults: {
          status: submissionStatus,
          tests: [testResults, bonusTestResults].flatMap((testResults, index) =>
            generateSubmissionTestArray({
              testResults,
              isBonus: index === 1,
            })
          ),
        },
        postUrl: links.postSubmission,
        readonlyRanges: getCodeMirrorFieldValue(
          editorView,
          readOnlyRangesStateField
        ),
      })
    },
    [
      setTestSuiteResult,
      setBonusTestSuiteResult,
      tasks,
      inspectedTestResult,
      shouldShowBonusTasks,
      bonusTasks,
    ]
  )

  return runCode
}

function generateSubmissionTestArray({
  testResults,
  isBonus = false,
}: {
  testResults: TestSuiteResult<NewTestResult>
  isBonus?: boolean
}) {
  return testResults.tests.map((test) => {
    return {
      slug: test.slug,
      status: test.status,
      ...(isBonus && { bonus: true }),
    }
  })
}
