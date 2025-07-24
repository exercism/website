import React, { useState, useCallback } from 'react'
import { Icon } from '../../common'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Iteration } from '../../types'
import { AutomatedFeedbackModal } from './AutomatedFeedbackModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const AutomatedFeedbackSummary = ({
  userIsStudent,
  iteration,
}: {
  userIsStudent: boolean
  iteration: Iteration
}): JSX.Element => {
  const { t } = useAppTranslation('session-batch-1')

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
        <div className="info">
          {t(
            userIsStudent
              ? 'components.mentoring.session.automatedFeedbackSummary.youReceivedAutomatedFeedback'
              : 'components.mentoring.session.automatedFeedbackSummary.studentReceivedAutomatedFeedback'
          )}
        </div>
        <Icon
          icon="modal"
          alt={t(
            'components.mentoring.session.automatedFeedbackSummary.opensInAModal'
          )}
          className="modal-icon"
        />
      </button>
      <AutomatedFeedbackModal
        iteration={iteration}
        open={modalOpen}
        onClose={handleModalClose}
      />
    </React.Fragment>
  )
}
