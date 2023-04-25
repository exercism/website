import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import { useChatGptFeedback } from './useChatGptFeedback'
import { useLogger } from '@/hooks'

type ChatGptFeedbackModalProps = {
  open: boolean
  onClose: () => void
  submission: Submission
}

export const ChatGptFeedbackModal = ({
  open,
  onClose,
  submission,
}: ChatGptFeedbackModalProps): JSX.Element => {
  const { advice } = useChatGptFeedback({
    submission,
  })

  useLogger('advice', advice)

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName="max-w-[40%]"
    >
      <div>Feedback modal</div>
    </Modal>
  ) //
}
