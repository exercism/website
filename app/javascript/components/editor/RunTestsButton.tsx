import React, { forwardRef } from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { GenericTooltip } from '../misc/ExercismTippy'

type Props = {
  haveFilesChanged: boolean
  isProcessing: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>

export const RunTestsButton = forwardRef<HTMLButtonElement, Props>(
  ({ haveFilesChanged, isProcessing, ...props }, ref) => {
    const isDisabled = !haveFilesChanged || isProcessing

    return (
      <GenericTooltip
        disabled={!isDisabled}
        content={'You have not made any changes since you last ran the tests'}
      >
        <div className="run-tests-btn">
          <button
            type="button"
            className="btn-enhanced btn-s"
            disabled={isDisabled}
            ref={ref}
            {...props}
          >
            <GraphicalIcon icon="run-tests" />
            <span>Run Tests</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
