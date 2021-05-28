import React from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import Tippy from '@tippyjs/react'
import { roundArrow } from 'tippy.js'

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
    <Tippy
      animation="shift-away-subtle"
      arrow={roundArrow}
      maxWidth="none"
      disabled={!isDisabled}
      content={
        <div className="c-generic-tooltip">
          You have not made any changes since you last ran the tests
        </div>
      }
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
    </Tippy>
  )
}
