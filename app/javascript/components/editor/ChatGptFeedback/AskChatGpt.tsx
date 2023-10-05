import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { LoadingBar } from '@/components/common/LoadingBar'
import type { useChatGptFeedbackProps, HelpRecord } from './useChatGptFeedback'

export function AskChatGpt({
  helpRecord,
  status,
  children,
}: Pick<useChatGptFeedbackProps, 'helpRecord' | 'status'> & {
  children: React.ReactNode
}): JSX.Element {
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
    case 'unfetched': {
      content = <Unfetched>{children}</Unfetched>
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
        <h2>ChatGPT&apos;s Suggestions</h2>

        <p>ChatGPT has the following suggestions:</p>

        <div dangerouslySetInnerHTML={{ __html: helpRecord.adviceHtml }} />

        <div className="text-h5-mono">Source: {helpRecord.source}</div>

        <div className="c-textblock-caution mb-16">
          <div className="c-textblock-header">
            Reminder: Use this advice wisely
          </div>
          <div className="c-textblock-content c-textblock-content text-16 leading-150">
            However clever ChatGPT appears, it does not &quot;understand&quot;
            code. Its suggestions may therefore be incorrect, muddled or
            misleading. However, it often provides useful insights to help
            unblock you.{' '}
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
      <GraphicalIcon icon="spinner" className="animate-spin-slow" />
      <LoadingBar animationDuration={15} />
      <p>
        <strong>Asking ChatGPT…</strong>
        <span>Estimated running time 15s</span>
      </p>
    </div>
  )
}

function Unfetched({ children }: { children: React.ReactNode }): JSX.Element {
  return (
    <section className="run-tests-prompt">
      <GraphicalIcon className="filter-textColor6" icon="automation" />
      <h2>Get unstuck with ChatGPT</h2>
      <p className="mb-32">
        If you&apos;re feeling stuck and can&apos;t seem to make progress,
        don&apos;t worry - just ask ChatGPT for help and get back on track.
      </p>
      {children}
    </section>
  )
}
