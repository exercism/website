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
        you simply don&apos;t wish to proceed further, it&apos;s time to end the
        discussion.
      </p>
      <div className="buttons">
        <button
          type="button"
          className="btn-small-discourage"
          onClick={() => onCancel()}
        >
          Cancel
        </button>
        <button
          type="button"
          className="btn-primary btn-s"
          onClick={() => onConfirm()}
        >
          Review and end discussion…
        </button>
      </div>
    </Modal>
  )
}
