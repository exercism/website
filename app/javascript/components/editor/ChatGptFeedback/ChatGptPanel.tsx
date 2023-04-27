import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { FetchingStatus, useChatGptFeedbackProps } from './useChatGptFeedback'
import { AskChatGpt } from './AskChatGpt'

export const ChatGptPanel = ({
  status,
  helpRecord,
}: {
  status: FetchingStatus
} & Pick<useChatGptFeedbackProps, 'helpRecord'>): JSX.Element => {
  return (
    <Tab.Panel id="chatgpt" context={TabsContext}>
      <section className="flex justify-center pb-16 px-24">
        <AskChatGpt status={status} helpRecord={helpRecord} />
      </section>
    </Tab.Panel>
  )
}
