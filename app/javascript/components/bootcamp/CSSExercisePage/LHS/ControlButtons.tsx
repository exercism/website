import React, { useCallback, useContext } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import {
  AssertionStatus,
  GRACE_THRESHOLD,
  PASS_THRESHOLD,
  useCSSExercisePageStore,
} from '../store/cssExercisePageStore'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { submitCode } from '../../JikiscriptExercisePage/hooks/useConstructRunCode/submitCode'
import { showResultToast } from './showResultToast'
import Icon from '@/components/common/Icon'
import { getCodeMirrorFieldValue } from '../../JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'
import { readOnlyRangesStateField } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { runHtmlChecks } from '../checks/runHtmlChecks'
import { CheckResult } from '../checks/runChecks'
import { runCssChecks } from '../checks/runCssChecks'
import { validateHtml5 } from '../../common/validateHtml5/validateHtml5'
import { normalizeHtmlText } from '../../common/validateHtml5/normalizeHtmlText'

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

  const { handleCompare, links, exercise, cssEditorRef, htmlEditorRef } =
    useContext(CSSExercisePageContext)

  const handleSubmitCode = useCallback(async () => {
    const { cssValue, htmlValue } = getEditorValues()
    const cssReadonlyRanges = getCodeMirrorFieldValue(
      cssEditorRef.current,
      readOnlyRangesStateField
    )
    const htmlReadonlyRanges = getCodeMirrorFieldValue(
      htmlEditorRef.current,
      readOnlyRangesStateField
    )
    const code = JSON.stringify({ css: cssValue, html: htmlValue })

    const percentage = await handleCompare()

    let status: AssertionStatus = 'fail'
    let firstFailingCheck: CheckResult | null = null

    if (htmlValue.length > 0) {
      const normalizedHtml = normalizeHtmlText(htmlValue)
      const isHTMLValid = validateHtml5(normalizedHtml)

      if (!isHTMLValid.isValid) {
        toast.error(
          `Your HTML is invalid (${isHTMLValid.errorMessage}). Please check the linter and look for hints on how to fix it.`
        )
        return
      }
    }

    const htmlChecks = await runHtmlChecks(exercise.htmlChecks, htmlValue)
    const cssChecks = await runCssChecks(exercise.cssChecks, cssValue)

    const allHtmlChecksPass = htmlChecks.success
    const allCssChecksPass =
      exercise.cssChecks.length === 0 || cssChecks.success

    if (allHtmlChecksPass && allCssChecksPass) {
      if (percentage >= GRACE_THRESHOLD) {
        status = 'grace'
      }
      if (percentage >= PASS_THRESHOLD) {
        status = 'pass'
      }
    } else {
      firstFailingCheck =
        htmlChecks.results.find((check) => !check.passes) ||
        cssChecks.results.find((check) => !check.passes) ||
        null
    }

    showResultToast(status, percentage, firstFailingCheck)
    updateAssertionStatus(status)

    submitCode({
      postUrl: links.postSubmission,
      code,
      testResults: {
        status: status === 'grace' ? 'pass' : status,
        tests: [],
      },
      customFunctions: [],
      readonlyRanges: { html: htmlReadonlyRanges, css: cssReadonlyRanges },
    })
  }, [
    exercise,
    getEditorValues,
    handleCompare,
    links.postSubmission,
    showResultToast,
    updateAssertionStatus,
    submitCode,
  ])

  const {
    panelSizes: { LHSWidth },
  } = useCSSExercisePageStore()

  return (
    <div
      style={{ width: LHSWidth }}
      className="flex py-8 gap-8 justify-between"
    >
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
