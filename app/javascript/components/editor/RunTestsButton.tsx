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
    placement: 'right',
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
        <div
          className="disabled-wrapper"
          {...mouseEvents}
          {...buttonAttributes}
        />
      </div>
      {open ? (
        <div
          className="c-tooltip"
          {...panelAttributes}
          style={{ ...panelAttributes.style }}
        >
          You have not made any changes since your last run
        </div>
      ) : null}
    </>
  )
}
