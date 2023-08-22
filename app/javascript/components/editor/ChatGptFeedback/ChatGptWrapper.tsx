import React from 'react'
import { FetchingStatus, useChatGptFeedbackProps } from './useChatGptFeedback'
import { AskChatGpt } from './AskChatGpt'

export const ChatGptWrapper = ({
  status,
  helpRecord,
  children,
}: {
  status: FetchingStatus
  children: React.ReactNode
} & Pick<useChatGptFeedbackProps, 'helpRecord'>): JSX.Element => {
  return (
    <section className="flex justify-center pb-16 px-24">
      <AskChatGpt status={status} helpRecord={helpRecord}>
        {children}
      </AskChatGpt>
    </section>
  )
}
