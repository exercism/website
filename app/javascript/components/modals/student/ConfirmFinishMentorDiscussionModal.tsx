import React from 'react'
import { Modal } from '../Modal'

export const ConfirmFinishMentorDiscussionModal = ({
  open,
  onConfirm,
  onCancel,
}: {
  open: boolean
  onCancel: () => void
  onConfirm: () => void
}): JSX.Element => {
  return (
    <Modal
      open={open}
      onClose={onCancel}
      className="m-confirm-finish-student-mentor-discussion"
    >
      <h3>Are you sure you want to end this discussion?</h3>
      <p>
        When you feel like the mentoring has reached its natural conclusion, or
        you simply don’t wish to proceed further, it's time to end the
        discussion.
      </p>
      <div className="buttons">
        <button
          type="button"
          className="btn-small-discourage"
          onClick={() => onCancel()}
        >
          Cancel
          <div className="kb-shortcut">F2</div>
        </button>
        <button
          type="button"
          className="btn-small-cta"
          onClick={() => onConfirm()}
        >
          Review and End discussion...
          <div className="kb-shortcut">F3</div>
        </button>
      </div>
    </Modal>
  )
}
