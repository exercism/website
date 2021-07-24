import React from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { ExercismGenericTooltip } from '../misc/ExercismTippy'

export const RunTestsButton = ({
  haveFilesChanged,
  isProcessing,
  ...props
}: {
  haveFilesChanged: boolean
  isProcessing: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>): JSX.Element => {
  const isDisabled = !haveFilesChanged || isProcessing

  return (
    <ExercismGenericTooltip
      disabled={!isDisabled}
      content={'You have not made any changes since you last ran the tests'}
    >
      <div className="run-tests-btn">
        <button
          type="button"
          className="btn-enhanced btn-s"
          disabled={isDisabled}
          {...props}
        >
          <GraphicalIcon icon="run-tests" />
          <span>Run Tests</span>
          <div className="kb-shortcut">F2</div>
        </button>
      </div>
    </ExercismGenericTooltip>
  )
}
