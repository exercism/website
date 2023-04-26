import React from 'react'
import { GraphicalIcon } from '@/components/common'
import type { useChatGptFeedbackProps, HelpRecord } from './useChatGptFeedback'

export function AskChatGpt({
  helpRecord,
  status,
}: Pick<useChatGptFeedbackProps, 'helpRecord' | 'status'>): JSX.Element {
  let content
  switch (status) {
    case 'fetching': {
      content = <AskingChatGpt />
      break
    }
    case 'received': {
      content = <ChatGptResponse helpRecord={helpRecord!} />
      break
    }
    default: {
      content = <div>Couldn&apos;t receive feedback</div>
    }
  }
  return <div className="c-chatgpt">{content} </div>
}

function ChatGptResponse({ helpRecord }: { helpRecord: HelpRecord }) {
  return (
    <div className="response">
      <div className="c-textual-content --small">
        <h2 className="">ChatGPT's Suggestions</h2>

        <p>ChatGPT has the following suggestions:</p>

        <div dangerouslySetInnerHTML={{ __html: helpRecord.advice_html }} />

        <div className="c-textblock-caution mb-16">
          <div className="c-textblock-header">
            Reminder: Use this advice wisely
          </div>
          <div className="c-textblock-content c-textblock-content text-16 leading-150">
            However clever ChatGPT appears, it does not "understand" code. Its
            suggestions may therefore be incorrect, muddled or misleading.
            However, it often provides useful insights to help unblock you.{' '}
            <strong className="font-medium">
              Use these suggestions as inspiration, not instruction.
            </strong>
          </div>
        </div>
      </div>
    </div>
  )
}

function AskingChatGpt() {
  return (
    <div role="status" className="running">
      <GraphicalIcon icon="spinner" />
      <div className="progress">
        <div
          className="bar"
          style={{
            animationDuration: '15s',
          }}
        />
      </div>
      <p>
        <strong>Asking ChatGPT...</strong>
        <span>Estimated running time 15s</span>
      </p>
    </div>
  )
}
