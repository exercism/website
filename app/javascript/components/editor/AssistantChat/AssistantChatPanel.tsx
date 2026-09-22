// i18n-key-prefix: assistantChatPanel
// i18n-namespace: components/editor/AssistantChat
import React, { useContext, useEffect, useRef, useState } from 'react'
import { Tab, GraphicalIcon, Avatar } from '@/components/common'
import { TabsContext } from '@/components/Editor'
import { highlightAll } from '@/utils/highlight'
import type { File } from '../../types'
import type { AssistantChatConfig, ChatMessage } from './types'
import { MAX_CHAT_MESSAGE_LENGTH } from './types'
import { useChat } from './useChat'
import { renderMarkdown } from './markdown'
import { InsidersUpsellModal } from './InsidersUpsellModal'
import { AssistantChatStartState } from './AssistantChatStartState'
import {
  deriveUsageStatus,
  usageLimitText,
  usageWarningText,
} from './chatUsage'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function AssistantChatPanel(props: {
  config: AssistantChatConfig
  solutionUuid: string
  insider: boolean
  getFiles: () => File[]
}): JSX.Element {
  return (
    <Tab.Panel id="assistant" context={TabsContext} alwaysAttachToDOM>
      <AssistantChatContent {...props} />
    </Tab.Panel>
  )
}

function AssistantChatContent({
  config,
  solutionUuid,
  insider,
  getFiles,
}: {
  config: AssistantChatConfig
  solutionUuid: string
  insider: boolean
  getFiles: () => File[]
}): JSX.Element {
  const chat = useChat(config, solutionUuid, getFiles)
  const allowed = config.allowed && !chat.accessDenied

  if (!allowed) {
    return (
      <div className="c-assistant-chat">
        <div className="chat-locked">
          {chat.messages.length > 0 ? (
            <>
              <MessageList
                messages={chat.messages}
                currentResponse=""
                status="idle"
                config={config}
              />
              <UpsellContent hasHistory config={config} />
            </>
          ) : (
            <UpsellContent hasHistory={false} config={config} />
          )}
        </div>
      </div>
    )
  }

  // Before the first message, show the landing state rather than an empty
  // transcript. The free conversation isn't consumed until a message is sent.
  if (chat.messages.length === 0 && !chat.currentResponse) {
    return (
      <div className="c-assistant-chat">
        <AssistantChatStartState
          insider={insider}
          onSendMessage={chat.sendMessage}
        />
      </div>
    )
  }

  return <Conversation chat={chat} config={config} />
}

function Conversation({
  chat,
  config,
}: {
  chat: ReturnType<typeof useChat>
  config: AssistantChatConfig
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/AssistantChat')
  const [draft, setDraft] = useState('')
  const usageStatus = deriveUsageStatus(chat.usage)
  const scrollRef = useRef<HTMLDivElement>(null)
  const configured = Boolean(config.chatUrl)
  const { current: currentTab } = useContext(TabsContext)

  useEffect(() => {
    if (currentTab !== 'assistant') return
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight })
  }, [chat.messages.length, chat.currentResponse, currentTab])

  const send = () => {
    const message = draft.trim()
    if (!message) return
    setDraft('')
    void chat.sendMessage(message)
  }

  const composerDisabled =
    !configured || chat.isDisabled || Boolean(usageStatus?.atCap)

  // Only surface the counter as the user nears the limit, so it doesn't clutter
  // the common case of short questions.
  const showCharCount = draft.length >= MAX_CHAT_MESSAGE_LENGTH * 0.8

  return (
    <div className="c-assistant-chat">
      <div ref={scrollRef} className="chat-scroll">
        <div className="chat-header">
          <h3>{t('assistantChatPanel.stuckAskYourAiAssistant')}</h3>
          <p>{t('assistantChatPanel.askAboutYourCode')}</p>
        </div>

        <MessageList
          messages={chat.messages}
          currentResponse={chat.currentResponse}
          status={chat.status}
          config={config}
        />
      </div>

      {chat.status === 'error' && chat.error ? (
        <div className="chat-status">
          <div className="message-text">{chat.error}</div>
          {chat.canRetry ? (
            <button type="button" onClick={chat.retryLastMessage}>
              {t('assistantChatPanel.tryAgain')}
            </button>
          ) : null}
        </div>
      ) : null}

      {!configured ? (
        <div className="chat-status">
          <div className="message-text">
            {t('assistantChatPanel.notAvailableRightNow')}
          </div>
        </div>
      ) : null}

      {usageStatus?.atCap ? (
        <div className="chat-usage at-cap">
          <span className="usage-text">
            {usageLimitText(usageStatus.scope, usageStatus.limit)}
          </span>
        </div>
      ) : usageStatus?.warning ? (
        <div className="chat-usage">
          <span className="usage-text">{usageWarningText(usageStatus)}</span>
        </div>
      ) : null}

      <div className="chat-input">
        <div className="chat-input-row">
          <div className="chat-input-avatar">
            <Avatar src={config.userAvatarUrl} handle={config.userHandle} />
          </div>
          <div className="chat-input-field">
            <textarea
              maxLength={MAX_CHAT_MESSAGE_LENGTH}
              placeholder={
                usageStatus?.atCap
                  ? t('assistantChatPanel.reachedYourMessageLimit')
                  : chat.isDisabled
                  ? t('assistantChatPanel.waitingForTheAssistant')
                  : chat.messages.length > 0
                  ? t('assistantChatPanel.respondToTheAssistant')
                  : t('assistantChatPanel.askAboutYourCodePlaceholder')
              }
              value={draft}
              disabled={composerDisabled}
              onChange={(e) => setDraft(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault()
                  send()
                }
              }}
            />
            {showCharCount ? (
              <span className="char-count">
                {draft.length}/{MAX_CHAT_MESSAGE_LENGTH}
              </span>
            ) : null}
            <button
              type="button"
              className="send-button"
              aria-label={t('assistantChatPanel.sendMessage')}
              disabled={composerDisabled || !draft.trim()}
              onClick={send}
            >
              <GraphicalIcon icon="arrow-right" />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

function MessageList({
  messages,
  currentResponse,
  status,
  config,
}: {
  messages: ChatMessage[]
  currentResponse: string
  status: string
  config: AssistantChatConfig
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/AssistantChat')

  return (
    <div className="chat-messages">
      {messages.length === 0 && !currentResponse ? (
        <MessageItem
          message={{
            role: 'assistant',
            content: t('assistantChatPanel.whatAreYouStuckOn'),
          }}
          config={config}
        />
      ) : null}

      {messages.map((message, i) => (
        <MessageItem key={i} message={message} config={config} />
      ))}

      {status === 'thinking' ? (
        <div className="message assistant thinking-row">
          <div className="avatar">
            <GraphicalIcon icon="exercism-face" />
          </div>
          <div className="content">
            <div className="thinking">
              <span />
              <span />
              <span />
            </div>
          </div>
        </div>
      ) : null}

      {currentResponse ? (
        <MessageItem
          message={{ role: 'assistant', content: currentResponse }}
          config={config}
        />
      ) : null}
    </div>
  )
}

function MessageItem({
  message,
  config,
}: {
  message: ChatMessage
  config: AssistantChatConfig
}): JSX.Element {
  const isUser = message.role === 'user'
  const contentRef = useRef<HTMLDivElement>(null)
  const html = renderMarkdown(message.content)

  // Re-highlight as the content changes, so code blocks in a streaming response
  // pick up highlighting rather than only doing so on mount.
  useEffect(() => {
    if (contentRef.current) {
      highlightAll(contentRef.current)
    }
  }, [html])

  return (
    <div className={`message ${isUser ? 'user' : 'assistant'}`}>
      <div className="avatar">
        {isUser ? (
          <Avatar src={config.userAvatarUrl} handle={config.userHandle} />
        ) : (
          <GraphicalIcon icon="exercism-face" />
        )}
      </div>
      <div
        ref={contentRef}
        className="content"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  )
}

const INSIDER_BENEFITS: { icon: string; key: string }[] = [
  { icon: 'robot', key: 'unlimitedAiAssistant' },
  { icon: 'perks', key: 'jikiPremium' },
  { icon: 'moon', key: 'darkMode' },
  { icon: 'feature-ad-free', key: 'adFree' },
  { icon: 'feature-youtube', key: 'behindTheScenes' },
  { icon: 'logo', key: 'supportExercism' },
]

function UpsellContent({
  hasHistory,
  config,
}: {
  hasHistory: boolean
  config: AssistantChatConfig
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/AssistantChat')
  const [modalOpen, setModalOpen] = useState(false)

  return (
    <div className="upsell">
      <div className="upsell-header">
        <div className="upsell-title">
          <h2>
            <Trans
              ns="components/editor/AssistantChat"
              i18nKey="assistantChatPanel.joinExercismInsiders"
              components={{
                gradient: <span className="text-gradient" />,
              }}
            />
          </h2>
          <p className="upsell-subtitle">
            {hasHistory
              ? t('assistantChatPanel.usedFreeConversationElsewhere')
              : t('assistantChatPanel.usedFreeConversation')}
          </p>
        </div>
      </div>

      <p className="upsell-blurb">
        {t('assistantChatPanel.everyoneGetsAConversation')}
      </p>

      <ul className="upsell-benefits">
        {INSIDER_BENEFITS.map((benefit) => (
          <li key={benefit.icon}>
            <GraphicalIcon icon={benefit.icon} />
            <div>
              <h3>
                {t(`assistantChatPanel.insiderBenefits.${benefit.key}.title`)}
              </h3>
              <p>
                {t(`assistantChatPanel.insiderBenefits.${benefit.key}.desc`)}
              </p>
            </div>
          </li>
        ))}
      </ul>

      <div className="upsell-cta">
        <button
          type="button"
          className="btn-l btn-primary"
          onClick={() => setModalOpen(true)}
        >
          {t('assistantChatPanel.becomeAnInsider')}
        </button>
        <p>{t('assistantChatPanel.tenAMonth')}</p>
      </div>

      <InsidersUpsellModal
        config={config.insidersUpsell}
        open={modalOpen}
        onClose={() => setModalOpen(false)}
      />
    </div>
  )
}
