import React, { useState, useEffect } from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import Tippy from '@tippyjs/react'

export const RunTestsButton = ({
  haveFilesChanged,
  isProcessing,
  ...props
}: {
  haveFilesChanged: boolean
  isProcessing: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>): JSX.Element => {
  const [open, setOpen] = useState(false)
  const isDisabled = !haveFilesChanged || isProcessing

  const mouseEvents = !haveFilesChanged
    ? { onMouseEnter: () => setOpen(true), onMouseLeave: () => setOpen(false) }
    : {}

  useEffect(() => {
    if (haveFilesChanged) {
      setOpen(false)
    }
  }, [haveFilesChanged, setOpen])

  return (
    <>
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
        <Tippy
          content={
            <div className="c-generic-tooltip">
              You have not made any changes since you last ran the tests
            </div>
          }
          disabled={!open}
        >
          <div className="disabled-wrapper" {...mouseEvents} />
        </Tippy>
      </div>
    </>
  )
}
