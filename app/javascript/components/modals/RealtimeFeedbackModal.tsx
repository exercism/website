import React from 'react'
import { SubmitButton } from '../editor/SubmitButton'
import { Modal } from './Modal'

type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
}
export const RealtimeFeedbackModal = ({
  open,
  onClose,
  onSubmit,
}: RealtimeFeedbackModalProps): JSX.Element => {
  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
    >
      <h3 className="text-h3 mb-16">Checking for automated feedback...</h3>
      {/* wait wait wait */}
      <div className="flex gap-8">
        <SubmitButton onClick={onSubmit} />
        <GoBackToExercise onClick={onClose} />
      </div>
    </Modal>
  )
}

function GoBackToExercise({ ...props }): JSX.Element {
  return (
    <button
      {...props}
      className="mr-16 px-[18px] py-[12px] border border-1 border-primaryBtnBorder text-primaryBtnBorder text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      Go back to exercise
    </button>
  )
}
