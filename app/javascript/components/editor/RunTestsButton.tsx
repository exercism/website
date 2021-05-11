import React, { useEffect } from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { usePanel } from '../../hooks/use-panel'

export const RunTestsButton = ({
  haveFilesChanged,
  isProcessing,
  ...props
}: {
  haveFilesChanged: boolean
  isProcessing: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>): JSX.Element => {
  const isDisabled = !haveFilesChanged || isProcessing
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'top',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  const mouseEvents = !haveFilesChanged
    ? { onMouseEnter: () => setOpen(true), onMouseLeave: () => setOpen(false) }
    : {}

  useEffect(() => {
    if (haveFilesChanged) {
      setOpen(false)
    }
  }, [haveFilesChanged, setOpen])

  return (
    <React.Fragment>
      <div {...buttonAttributes} {...mouseEvents}>
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
      {open ? (
        <div {...panelAttributes}>
          You have not made any changes since your last run
        </div>
      ) : null}
    </React.Fragment>
  )
}
