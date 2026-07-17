import React, { useEffect, useRef, useState } from 'react'
import { Tab, GraphicalIcon } from '@/components/common'
import { TabsContext } from '@/components/Editor'
import type { File } from '../../types'
import type { AssistantChatConfig, ChatMessage } from './types'
import { MAX_CHAT_MESSAGE_LENGTH } from './types'
import { useChat } from './useChat'
import {
  deriveUsageStatus,
  usageLimitText,
  usageWarningText,
} from './chatUsage'

export function AssistantChatPanel(props: {
  config: AssistantChatConfig
  solutionUuid: string
  getFiles: () => File[]
}): JSX.Element {
  return (
    <Tab.Panel id="assistant" context={TabsContext}>
      <AssistantChatContent {...props} />
    </Tab.Panel>
  )
}

function AssistantChatContent({
  config,
  solutionUuid,
  getFiles,
}: {
  config: AssistantChatConfig
  solutionUuid: string
  getFiles: () => File[]
}): JSX.Element {
  const chat = useChat(config, solutionUuid, getFiles)
  const allowed = config.allowed && !chat.accessDenied

  if (!allowed) {
    return (
      <div className="px-24 pt-16 pb-24 overflow-y-auto">
        {chat.messages.length > 0 ? (
          <>
            <ConversationList
              messages={chat.messages}
              currentResponse=""
              status="idle"
            />
            <UpsellContent hasHistory />
          </>
        ) : (
          <UpsellContent hasHistory={false} />
        )}
      </div>
    )
  }

  return <Conversation chat={chat} configured={Boolean(config.chatUrl)} />
}

function Conversation({
  chat,
  configured,
}: {
  chat: ReturnType<typeof useChat>
  configured: boolean
}): JSX.Element {
  const [draft, setDraft] = useState('')
  const usageStatus = deriveUsageStatus(chat.usage)
  const scrollRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight })
  }, [chat.messages.length, chat.currentResponse])

  const send = () => {
    const message = draft.trim()
    if (!message) return
    setDraft('')
    void chat.sendMessage(message)
  }

  const composerDisabled =
    !configured || chat.isDisabled || Boolean(usageStatus?.atCap)

  return (
    <div className="flex flex-col h-full">
      <div ref={scrollRef} className="flex-grow overflow-y-auto px-24 py-16">
        {chat.messages.length === 0 && !chat.currentResponse ? (
          <EmptyState />
        ) : null}
        <ConversationList
          messages={chat.messages}
          currentResponse={chat.currentResponse}
          status={chat.status}
        />
        {chat.status === 'error' && chat.error ? (
          <div className="c-textblock-caution mb-16 p-12">
            <div className="c-textblock-content text-15 mb-8">{chat.error}</div>
            {chat.canRetry ? (
              <button
                type="button"
                className="btn-s btn-default"
                onClick={chat.retryLastMessage}
              >
                Try again
              </button>
            ) : null}
          </div>
        ) : null}
      </div>

      <div className="border-t-1 border-borderColor6 px-24 py-12">
        {!configured ? (
          <div className="text-15 text-textColor6 mb-8">
            The AI assistant isn&apos;t available right now.
          </div>
        ) : null}
        {usageStatus?.atCap ? (
          <div className="text-15 text-textColor6 mb-8">
            {usageLimitText(usageStatus.scope, usageStatus.limit)}
          </div>
        ) : usageStatus?.warning ? (
          <div className="text-15 text-textColor6 mb-8">
            {usageWarningText(usageStatus)}
          </div>
        ) : null}
        <div className="flex items-end gap-8">
          <textarea
            className="flex-grow border-1 border-borderColor6 rounded-8 px-12 py-8 text-15"
            rows={2}
            maxLength={MAX_CHAT_MESSAGE_LENGTH}
            placeholder="Ask about your code, the tests, or the exercise…"
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
          <button
            type="button"
            className="btn-m btn-primary"
            disabled={composerDisabled || !draft.trim()}
            onClick={send}
          >
            Send
          </button>
        </div>
        <div className="text-13 text-textColor6 mt-8">
          The assistant guides you towards a solution rather than giving you
          answers. It can make mistakes, so check anything important against the
          exercise and its tests.
        </div>
      </div>
    </div>
  )
}

function ConversationList({
  messages,
  currentResponse,
  status,
}: {
  messages: ChatMessage[]
  currentResponse: string
  status: string
}): JSX.Element {
  return (
    <div className="flex flex-col gap-12 mb-16">
      {messages.map((message, i) => (
        <MessageBubble key={i} message={message} />
      ))}
      {status === 'thinking' ? (
        <div className="text-15 text-textColor6 italic">Thinking…</div>
      ) : null}
      {currentResponse ? (
        <MessageBubble
          message={{ role: 'assistant', content: currentResponse }}
        />
      ) : null}
    </div>
  )
}

function MessageBubble({ message }: { message: ChatMessage }): JSX.Element {
  if (message.role === 'user') {
    return (
      <div className="self-end max-w-[85%] bg-backgroundColorD rounded-8 px-12 py-8 text-15 whitespace-pre-wrap">
        {message.content}
      </div>
    )
  }
  return (
    <div className="self-start max-w-[85%] border-1 border-borderColor6 rounded-8 px-12 py-8 text-15 whitespace-pre-wrap">
      {message.content}
    </div>
  )
}

function EmptyState(): JSX.Element {
  return (
    <section className="run-tests-prompt mb-16">
      <GraphicalIcon className="filter-textColor6" icon="automation" />
      <h2>Stuck? Ask the AI assistant</h2>
      <p>
        Ask a question about your code, the tests, or the exercise and get a
        nudge in the right direction. It won&apos;t give you the answer, but it
        will help you find it.
      </p>
    </section>
  )
}

function UpsellContent({ hasHistory }: { hasHistory: boolean }): JSX.Element {
  return (
    <div className="text-center">
      <div className="border-gradient-lightPurple border-2 rounded-8 px-24 py-16 flex flex-col items-center">
        <GraphicalIcon icon="insiders" className="w-[48px] h-[48px] mb-16" />
        <h2 className="text-h3 mb-2">Exercism Insiders</h2>
        <p className="text-h5 mb-16 max-w-[520px]">
          {hasHistory
            ? "You've used your free AI conversation on another exercise."
            : "You've used your free AI conversation."}
        </p>
        <div className="text-p-base max-w-[520px] mb-16">
          Everyone gets an AI assistant conversation on one exercise for free.
          Join Insiders to unlock unlimited conversations on every exercise, and
          get behind-the-scenes access and bonus features.
        </div>

        <a href="/insiders" className="btn-m btn-primary">
          Learn more
        </a>
      </div>
    </div>
  )
}
