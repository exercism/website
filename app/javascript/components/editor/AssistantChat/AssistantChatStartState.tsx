// i18n-key-prefix: assistantChatStartState
// i18n-namespace: components/editor/AssistantChat
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { MAX_CHAT_MESSAGE_LENGTH } from './types'

const ROTATING_PHRASE_KEYS = [
  'whyThisIsntWorking',
  'howToFixThisBug',
  'whatThisErrorMeans',
  'howToApproachThis',
  'howToGetUnstuck',
]

const TYPE_MS = 50
const DELETE_MS = 30
const HOLD_MS = 2000

// A small typewriter, rather than pulling in typeit-react for one line of
// decoration. Types a phrase, holds, deletes it, moves to the next.
function useRotatingPhrase(phrases: string[]): string {
  const [index, setIndex] = useState(0)
  const [length, setLength] = useState(0)
  const [deleting, setDeleting] = useState(false)

  useEffect(() => {
    const phrase = phrases[index]

    if (!deleting && length === phrase.length) {
      const timer = setTimeout(() => setDeleting(true), HOLD_MS)
      return () => clearTimeout(timer)
    }

    if (deleting && length === 0) {
      setDeleting(false)
      setIndex((i) => (i + 1) % phrases.length)
      return
    }

    const timer = setTimeout(
      () => setLength((l) => l + (deleting ? -1 : 1)),
      deleting ? DELETE_MS : TYPE_MS
    )
    return () => clearTimeout(timer)
  }, [phrases, index, length, deleting])

  return phrases[index].slice(0, length)
}

export function AssistantChatStartState({
  insider,
  onSendMessage,
}: {
  insider: boolean
  onSendMessage: (message: string) => void
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/AssistantChat')
  const [message, setMessage] = useState('')
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const phrases = useMemo(
    () =>
      ROTATING_PHRASE_KEYS.map((key) =>
        t(`assistantChatStartState.rotatingPhrases.${key}`)
      ),
    [t]
  )
  const phrase = useRotatingPhrase(phrases)
  const hasMessage = message.trim().length > 0

  useEffect(() => {
    textareaRef.current?.focus()
  }, [])

  // Grow the textarea with its contents. The minimum lives in CSS (it varies
  // with the panel's width), so scrollHeight is used as-is and min-height
  // does the flooring.
  useEffect(() => {
    const el = textareaRef.current
    if (!el) return
    el.style.height = 'auto'
    el.style.height = `${el.scrollHeight}px`
  }, [message])

  const send = () => {
    if (!hasMessage) return
    onSendMessage(message.trim())
    setMessage('')
  }

  return (
    <div className="chat-start">
      <div className="chat-start-content">
        <div className="chat-start-avatar">
          <GraphicalIcon icon="conversation-chat" />
        </div>
        <h3>{t('assistantChatStartState.feelingStuck')}</h3>
        <p className="chat-start-description">
          {t('assistantChatStartState.askOurAssistantAbout')}{' '}
          <span className="rotating-text">
            {phrase}
            <span className="cursor" />
          </span>
        </p>

        <div className="chat-start-input">
          <textarea
            ref={textareaRef}
            value={message}
            maxLength={MAX_CHAT_MESSAGE_LENGTH}
            placeholder={t('assistantChatStartState.tellUsWhatYoureStuckOn')}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault()
                send()
              }
            }}
          />
          <button
            type="button"
            className={`chat-start-send ${hasMessage ? '--active' : ''}`}
            disabled={!hasMessage}
            onClick={send}
          >
            <GraphicalIcon icon="conversation-chat" />
            {t('assistantChatStartState.askOurAssistant')}
          </button>
        </div>

        <p className="chat-start-included">
          <GraphicalIcon icon="check-circle" />
          <span>
            {insider
              ? t('assistantChatStartState.unlimitedConversations')
              : t('assistantChatStartState.getAssistantHelpFree')}
          </span>
        </p>
      </div>
    </div>
  )
}
