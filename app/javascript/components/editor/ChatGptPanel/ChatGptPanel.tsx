import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { Submission } from '../types'
import {
  FetchingStatus,
  useChatGptFeedbackProps,
} from '../ChatGptFeedback/useChatGptFeedback'
import { AskChatGpt } from '../AskChatGpt/AskChatGpt'

export const ChatGptPanel = ({
  status,
  helpRecord,
  mutation,
}: {
  submission: Submission
  status: FetchingStatus
} & Pick<useChatGptFeedbackProps, 'helpRecord' | 'mutation'>): JSX.Element => {
  return (
    <Tab.Panel id="chatgpt" context={TabsContext}>
      <section className="flex justify-center py-12 px-8">
        <AskChatGpt
          status={status}
          helpRecord={helpRecord}
          mutation={mutation}
        />
      </section>
    </Tab.Panel>
  )
}
