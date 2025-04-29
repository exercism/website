import React, { useCallback, useContext } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import {
  PASS_THRESHOLD,
  useCSSExercisePageStore,
} from '../store/cssExercisePageStore'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { submitCode } from '../../JikiscriptExercisePage/hooks/useConstructRunCode/submitCode'
import { CheckResult, runChecks } from '../utils/runCheckFunctions'
import { showResultToast } from './showResultToast'

export function ControlButtons({
  getEditorValues,
}: {
  getEditorValues: () => { cssValue: string; htmlValue: string }
}) {
  const {
    isDiffModeOn,
    diffMode,
    toggleDiffMode,
    curtainMode,
    toggleCurtainMode,
    toggleIsDiffModeOn,
    updateAssertionStatus,
  } = useCSSExercisePageStore()

  const { handleCompare, links, exercise } = useContext(CSSExercisePageContext)

  const handleSubmitCode = useCallback(async () => {
    const { cssValue, htmlValue } = getEditorValues()
    const code = JSON.stringify({ css: cssValue, html: htmlValue })

    const percentage = await handleCompare()

    let status: 'pass' | 'fail' = 'fail'
    let firstFailingCheck: CheckResult | null = null

    if (percentage >= PASS_THRESHOLD) {
      if (exercise.checks.length === 0) {
        status = 'pass'
      } else {
        const checks = runChecks(exercise.checks, cssValue)

        if (checks.success) {
          status = 'pass'
        } else {
          firstFailingCheck =
            checks.results.find((check) => !check.passes) || null
        }
      }
    }

    showResultToast(status, percentage, firstFailingCheck)
    updateAssertionStatus(status)

    submitCode({
      postUrl: links.postSubmission,
      code,
      testResults: {
        status,
        tests: [],
      },
      customFunctions: [],
      readonlyRanges: [],
    })
  }, [
    getEditorValues,
    handleCompare,
    exercise,
    showResultToast,
    updateAssertionStatus,
    submitCode,
    links.postSubmission,
  ])

  return (
    <div className="flex py-8 justify-between">
      <button onClick={handleSubmitCode} className="btn-primary btn-s">
        Check Result
      </button>
      <div className="flex gap-8">
        <button
          onClick={toggleCurtainMode}
          className={assembleClassNames('btn-secondary btn-s')}
        >
          Curtain: {curtainMode ? 'on' : 'off'}
        </button>
        <div>
          <button
            onClick={toggleIsDiffModeOn}
            className={assembleClassNames('btn-secondary btn-s')}
          >
            Diff: {isDiffModeOn ? 'on' : 'off'}
          </button>

          <button
            onClick={toggleDiffMode}
            className={assembleClassNames('btn-secondary btn-s')}
          >
            mode: {diffMode}
          </button>
        </div>
      </div>
    </div>
  )
}
