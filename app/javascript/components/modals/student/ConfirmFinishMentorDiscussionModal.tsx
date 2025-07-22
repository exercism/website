// i18n-key-prefix: confirmFinishMentorDiscussionModal
// i18n-namespace: components/modals/student
import React from 'react'
import { Modal } from '../Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ConfirmFinishMentorDiscussionModal = ({
  open,
  onConfirm,
  onCancel,
}: {
  open: boolean
  onCancel: () => void
  onConfirm: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/student')

  return (
    <Modal
      open={open}
      onClose={onCancel}
      className="m-confirm-finish-student-mentor-discussion"
    >
      <h3>{t('confirmFinishMentorDiscussionModal.areYouSure')}</h3>
      <p>
        {t(
          'confirmFinishMentorDiscussionModal.feelLikeMentoringReachedConclusion'
        )}
      </p>
      <div className="buttons">
        <button
          type="button"
          className="btn-small-discourage"
          onClick={() => onCancel()}
        >
          {t('confirmFinishMentorDiscussionModal.cancel')}
        </button>
        <button
          type="button"
          className="btn-primary btn-s"
          onClick={() => onConfirm()}
        >
          {t('confirmFinishMentorDiscussionModal.reviewAndEndDiscussion')}
        </button>
      </div>
    </Modal>
  )
}
