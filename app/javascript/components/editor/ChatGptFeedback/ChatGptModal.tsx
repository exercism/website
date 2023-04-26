import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import {
  useChatGptFeedback,
  useChatGptFeedbackProps,
} from './useChatGptFeedback'
import { useLogger } from '@/hooks'
import { AskChatGptButton } from './AskChatGptButton'
import { GraphicalIcon } from '@/components/common'

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
  const { helpRecord, mutation } = useChatGptFeedback({
    submission,
  })

  useLogger('helpRecord', helpRecord)

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName="max-w-[40%]"
    >
      <AskChatGpt helpRecord={helpRecord} mutation={mutation} />
    </Modal>
  )
}

function AskChatGpt({ helpRecord, mutation }: useChatGptFeedbackProps) {
  return (
    <div>
      <h2 className="text-h2">Ask ChatGPT</h2>
      {helpRecord === undefined ? (
        <AskChatGptButton onClick={() => mutation()} />
      ) : helpRecord === null ? (
        <GraphicalIcon icon="spinner" className="c-spinner" />
      ) : (
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: helpRecord.advice_html }}
        />
      )}
    </div>
  )
}
