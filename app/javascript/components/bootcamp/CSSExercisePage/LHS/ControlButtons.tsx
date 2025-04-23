import React, { useCallback, useContext } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { submitCode } from '../../JikiscriptExercisePage/hooks/useConstructRunCode/submitCode'
import { runChecks } from '../utils/runCheckFunctions'

export function ControlButtons({
  getEditorValues,
}: {
  getEditorValues: () => { cssValue: string; htmlValue: string }
}) {
  const {
    diffMode,
    curtainMode,
    toggleCurtainMode,
    toggleDiffMode,
    setMatchPercentage,
  } = useCSSExercisePageStore()

  const { handleCompare, links, exercise } = useContext(CSSExercisePageContext)

  const handleSubmitCode = useCallback(async () => {
    const { cssValue, htmlValue } = getEditorValues()

    const checks = runChecks(exercise.checks, cssValue)
    console.log('checks', checks)

    const code = JSON.stringify({ css: cssValue, html: htmlValue })

    const percentage = await handleCompare()

    setMatchPercentage(percentage)

    submitCode({
      postUrl: links.postSubmission,
      code,
      testResults: {
        status: percentage === 100 ? 'pass' : 'fail',
        tests: [],
      },
      customFunctions: [],
      readonlyRanges: [],
    })
  }, [])

  return (
    <div className="flex py-8 justify-between">
      <button onClick={handleSubmitCode} className="btn-primary btn-s">
        Compare
      </button>
      <div className="flex gap-8">
        <button
          onClick={toggleCurtainMode}
          className={assembleClassNames('btn-secondary btn-s')}
        >
          Curtain: {curtainMode ? 'on' : 'off'}
        </button>
        <button
          onClick={toggleDiffMode}
          className={assembleClassNames('btn-secondary btn-s')}
        >
          Diff: {diffMode ? 'on' : 'off'}
        </button>
      </div>
    </div>
  )
}
