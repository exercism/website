import React, { useCallback } from 'react'
import { Icon } from '../../common/Icon'
import { usePanel } from './usePanel'

export const ActionMore = ({
  onRevertToLastIteration,
  onRevertToExerciseStart,
  isRevertToLastIterationDisabled,
}: {
  onRevertToLastIteration: () => void
  onRevertToExerciseStart: () => void
  isRevertToLastIterationDisabled: boolean
}): JSX.Element => {
  const {
    open,
    setOpen,
    buttonRef,
    panelRef,
    componentRef,
    styles,
    attributes,
  } = usePanel()

  const handleRevertToLastIteration = useCallback(() => {
    onRevertToLastIteration()

    setOpen(false)
  }, [onRevertToLastIteration, setOpen])

  const handleRevertToExerciseStart = useCallback(() => {
    onRevertToExerciseStart()

    setOpen(false)
  }, [onRevertToExerciseStart, setOpen])

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        className="more-btn"
        onClick={() => {
          setOpen(!open)
        }}
      >
        <Icon icon="more-horizontal" alt="Open more options" />
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div>
            <button type="button" onClick={handleRevertToExerciseStart}>
              Revert to exercise start
            </button>
            <button
              onClick={handleRevertToLastIteration}
              type="button"
              disabled={isRevertToLastIterationDisabled}
            >
              Revert to last iteration submission
            </button>
          </div>
        ) : null}
      </div>
    </div>
  )
}
