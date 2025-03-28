import React, { useContext } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { CSSExercisePageContext } from '../CSSExercisePageContext'

export function ControlButtons() {
  const { diffMode, curtainMode, toggleCurtainMode, toggleDiffMode } =
    useCSSExercisePageStore()
  const { handleCompare } = useContext(CSSExercisePageContext)
  return (
    <div className="flex py-8 justify-between">
      <button onClick={handleCompare} className="btn-primary btn-s">
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
