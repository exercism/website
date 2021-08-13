import React, { useState, useCallback } from 'react'
import { Icon } from '../../common'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Iteration } from '../../types'
import { AutomatedFeedbackModal } from './AutomatedFeedbackModal'

export const AutomatedFeedbackSummary = ({
  userIsStudent,
  iteration,
}: {
  userIsStudent: boolean
  iteration: Iteration
}): JSX.Element => {
  const addressedTo = userIsStudent ? 'You' : 'Student'

  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <button className="auto-feedback" onClick={handleModalOpen} type="button">
        <GraphicalIcon icon="automation" className="info-icon" />
        <div className="info">{addressedTo} received automated feedback</div>
        <Icon icon="modal" alt="Opens in a modal" className="modal-icon" />
      </button>
      <AutomatedFeedbackModal
        iteration={iteration}
        open={modalOpen}
        onClose={handleModalClose}
      />
    </React.Fragment>
  )
}
