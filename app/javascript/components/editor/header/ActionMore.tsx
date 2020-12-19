import React, { useCallback, useEffect, useState } from 'react'
import { Icon } from '../../common/Icon'
import { BugReportModal } from '../../modals/BugReportModal'
import { usePanel } from '../../../hooks/use-panel'

export const ActionMore = ({
  onRevertToLastIteration,
  onRevertToExerciseStart,
  isRevertToLastIterationDisabled,
}: {
  onRevertToLastIteration: () => void
  onRevertToExerciseStart: () => void
  isRevertToLastIterationDisabled: boolean
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)
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
  const handleOpenReport = useCallback(() => {
    setIsModalOpen(true)

    setOpen(false)
  }, [setOpen, setIsModalOpen])

  return (
    <div ref={componentRef}>
      <BugReportModal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
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
            <button type="button" onClick={handleOpenReport}>
              Report a bug
            </button>
          </div>
        ) : null}
      </div>
    </div>
  )
}
