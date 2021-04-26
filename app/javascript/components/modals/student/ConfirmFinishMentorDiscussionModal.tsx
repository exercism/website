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
        It&apos;s normally time to end a discussion when the student has got
        what they wanted from the conversation, or you have taken the
        conversation as far as you like. It&apos;s generally polite to leave the
        student a final goodbye.
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
          End discussion
          <div className="kb-shortcut">F3</div>
        </button>
      </div>
    </Modal>
  )
}
