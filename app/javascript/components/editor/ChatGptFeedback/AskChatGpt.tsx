// i18n-key-prefix: askChatGpt
// i18n-namespace: components/editor/ChatGptFeedback
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { LoadingBar } from '@/components/common/LoadingBar'
import type { useChatGptFeedbackProps, HelpRecord } from './useChatGptFeedback'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function AskChatGpt({
  helpRecord,
  status,
  children,
}: Pick<useChatGptFeedbackProps, 'helpRecord' | 'status'> & {
  children: React.ReactNode
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')
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
      content = <div>{t('askChatGpt.couldntReceiveFeedback')}</div>
    }
  }
  return <div className="c-chatgpt">{content} </div>
}

function ChatGptResponse({ helpRecord }: { helpRecord: HelpRecord }) {
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')

  return (
    <div className="response">
      <div className="c-textual-content --small">
        <h2>{t('askChatGpt.chatGptsSuggestions')}</h2>

        <p>{t('askChatGpt.chatGptHasTheFollowingSuggestions')}</p>

        <div dangerouslySetInnerHTML={{ __html: helpRecord.adviceHtml }} />

        <div className="text-h5-mono">Source: {helpRecord.source}</div>

        <div className="c-textblock-caution mb-16">
          <div className="c-textblock-header">
            {t('askChatGpt.reminderUseThisAdviceWisely')}
          </div>
          <div className="c-textblock-content c-textblock-content text-16 leading-150">
            <Trans
              i18nKey="askChatGpt.howeverCleverChatGptAppearsItDoesNotUnderstandCode"
              ns="components/editor/ChatGptFeedback"
              components={{ bold: <strong className="font-semibold" /> }}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

function AskingChatGpt() {
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')

  return (
    <div role="status" className="running">
      <GraphicalIcon
        icon="spinner"
        className="animate-spin-slow filter-textColor6"
      />
      <LoadingBar animationDuration={15} />
      <p>
        <strong>{t('askChatGpt.askingChatGPT')}</strong>
        <span>{t('askChatGpt.estimatedRunningTime15s')}</span>
      </p>
    </div>
  )
}

function Unfetched({ children }: { children: React.ReactNode }): JSX.Element {
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')

  return (
    <section className="run-tests-prompt">
      <GraphicalIcon className="filter-textColor6" icon="automation" />
      <h2>{t('askChatGpt.getUnstuckWithChatGPT')}</h2>
      <p className="mb-32">
        {t('askChatGpt.ifYoureFeelingStuckAndCantSeemToMakeProgress')}
      </p>
      {children}
    </section>
  )
}
