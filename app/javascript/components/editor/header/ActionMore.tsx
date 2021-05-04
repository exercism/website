import React, { useCallback, useState } from 'react'
import { GraphicalIcon, Icon } from '../../common'
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
  const { open, setOpen, panelAttributes, buttonAttributes } = usePanel()

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
    <React.Fragment>
      <BugReportModal
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <button
        {...buttonAttributes}
        onClick={() => setOpen(!open)}
        className="more-btn"
      >
        <Icon icon="more-horizontal" alt="Open more options" />
      </button>
      {open ? (
        <div {...panelAttributes} className="actions-dialog">
          <ul>
            <li>
              <button type="button" onClick={handleRevertToExerciseStart}>
                <GraphicalIcon icon="reset" />
                Revert to exercise start
              </button>
            </li>
            <li>
              <button
                onClick={handleRevertToLastIteration}
                type="button"
                disabled={isRevertToLastIterationDisabled}
              >
                <GraphicalIcon icon="reset" />
                Revert to last iteration submission
              </button>
            </li>
            <li>
              <button type="button" onClick={handleOpenReport}>
                <GraphicalIcon icon="bug" />
                Report a bug
              </button>
            </li>
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
