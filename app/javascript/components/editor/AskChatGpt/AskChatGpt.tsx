import { GraphicalIcon } from '@/components/common'
import React from 'react'
import { AskChatGptButton } from '../ChatGptFeedback/AskChatGptButton'
import {
  useChatGptFeedbackProps,
  HelpRecord,
} from '../ChatGptFeedback/useChatGptFeedback'

export function AskChatGpt({
  helpRecord,
  mutation,
  status,
}: Pick<
  useChatGptFeedbackProps,
  'helpRecord' | 'mutation' | 'status'
>): JSX.Element {
  switch (status) {
    case 'unfetched':
      return (
        <div>
          <AskChatGptButton onClick={() => mutation()} />
        </div>
      )
    case 'fetching':
      return <AskingChatGpt />
    case 'received':
      if (helpRecord) {
        return <ChatGptResponse helpRecord={helpRecord} />
      } else return <div>Couldn&apos;t receive feedback</div>
  }
}

function ChatGptResponse({ helpRecord }: { helpRecord: HelpRecord }) {
  return (
    <div className="c-textblock-chatgpt">
      <div className="c-textblock-header">{helpRecord.source} says:</div>
      <div
        className="c-textual-content --base p-12"
        dangerouslySetInnerHTML={{ __html: helpRecord.advice_html }}
      />
    </div>
  )
}

function AskingChatGpt() {
  return (
    <div className="flex flex-col gap-16">
      <strong className="text-h5-mono flex items-center gap-8">
        <GraphicalIcon icon="spinner" className="c-spinner" />
        Asking ChatGPT...
      </strong>
      <span className="text-p-small">Estimated running time ~ 15s</span>
    </div>
  )
}
