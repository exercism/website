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
import useCustomFunctionStore from '@/components/bootcamp/CustomFunctionEditor/store/customFunctionsStore'
import { framesSucceeded } from '@/interpreter/frames'

export function useConstructRunCode({
  links,
  config,
  language,
}: Pick<JikiscriptExercisePageProps, 'links'> & {
  config: Config
  language: Exercise['language']
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
      editorView,
    })

    setTestSuiteResult(null)
    setInspectedTestResult(null)
  }

  const { customFunctionsForInterpreter, getSelectedCustomFunctions } =
    useCustomFunctionStore()

  /**
   * This function is used to run the code in the editor
   */
  const runCode = useCallback(
    async (studentCode: string, editorView: EditorView | null) => {
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

      if (language === 'jikiscript') {
        const compiled = compile(studentCode, {
          languageFeatures: config.interpreterOptions,
          customFunctions: Object.values(customFunctionsForInterpreter).map(
            (cfn) => {
              return { name: cfn.name, arity: cfn.arity, code: cfn.code }
            }
          ),
        })

        const error = compiled.error as CompilationError

        if (error) {
          handleCompilationError(error, editorView)
          return
        }
      }

      let testResults

      const customFns = Object.values(customFunctionsForInterpreter).map(
        (cfn) => {
          return {
            name: cfn.name,
            arity: cfn.arity,
            code: cfn.code,
          }
        }
      )
      // try {
      testResults = await generateAndRunTestSuite(
        {
          studentCode,
          tasks,
          config,
          customFunctions: customFns,
        },
        {
          setUnderlineRange,
          setHighlightedLine,
          setHighlightedLineColor,
          setShouldShowInformationWidget,
          setInformationWidgetData,
        },
        editorView,
        language
      )
      // console.log("Thinks I've run", testResults.tests.length)
      // } catch (error) {
      //   console.log(error)
      //   const compError = error as CompilationError
      //   if (
      //     compError.hasOwnProperty('type') &&
      //     compError.type == 'CompilationError'
      //   ) {
      //     handleCompilationError(compError.error, editorView)
      //     return
      //   }
      //   console.log(compError)
      // }
      console.log('No error')

      const bonusTestResults = await generateAndRunTestSuite(
        {
          studentCode,
          tasks: bonusTasks ?? [],
          config,
          customFunctions: customFns,
        },
        {
          setUnderlineRange,
          setHighlightedLine,
          setHighlightedLineColor,
          setShouldShowInformationWidget,
          setInformationWidgetData,
        },
        editorView,
        language
      )

      setTestSuiteResult(testResults)
      setBonusTestSuiteResult(bonusTestResults)

      markTaskAsCompleted(testResults)

      const automaticallyInspectedTest = getFirstFailingOrLastTest(
        testResults,
        bonusTestResults,
        inspectedTestResult,
        shouldShowBonusTasks
      )

      // Don't play out the animation if there are errors
      // The scrubber will automatically handle jumping to
      // the first error.
      //
      // Note: If you ever change this, check your new code with
      // a runtime error on the first line.
      if (framesSucceeded(automaticallyInspectedTest.frames)) {
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
        customFunctions: getSelectedCustomFunctions(),
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
      customFunctionsForInterpreter,
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
