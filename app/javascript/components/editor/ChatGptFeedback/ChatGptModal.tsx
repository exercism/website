import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import { useChatGptFeedback } from './useChatGptFeedback'

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
  const { helpRecord } = useChatGptFeedback({
    submission,
  })

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName={`max-w-[40%] ${helpRecord && '!p-0'}`}
    ></Modal>
  )
}
