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
import Icon from '@/components/common/Icon'
import { runHtmlChecks } from '../utils/runHtmlChecks'

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

    const htmlChecks = runHtmlChecks(exercise.htmlChecks, htmlValue)
    console.log('htmlchecks', htmlChecks, exercise.cssChecks)
    if (percentage >= PASS_THRESHOLD) {
      if (exercise.cssChecks.length === 0) {
        status = 'pass'
      } else {
        const cssChecks = runChecks(exercise.cssChecks, cssValue)

        if (cssChecks.success) {
          status = 'pass'
        } else {
          firstFailingCheck =
            cssChecks.results.find((check) => !check.passes) || null
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
        <div className="btn-secondary btn-s flex gap-4 p-0 overflow-hidden">
          <button onClick={toggleIsDiffModeOn} className="p-4 px-16">
            Diff: {isDiffModeOn ? 'on' : 'off'}
          </button>

          <button
            className="border-l-1 border-l-borderColor4 bg-lightPurpleDarkened h-full px-4"
            onClick={toggleDiffMode}
          >
            <Icon
              className="border-1 border-borderColor5"
              icon={`${diffMode}-diff.svg`}
              alt={'diff-mode'}
              height={24}
              width={24}
            />
          </button>
        </div>
      </div>
    </div>
  )
}
