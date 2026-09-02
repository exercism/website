import React, { useEffect, useRef, useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { MAX_CHAT_MESSAGE_LENGTH } from './types'

const ROTATING_PHRASES = [
  'why this isn’t working',
  'how to fix this bug',
  'what this error means',
  'how to approach this',
  'how to get unstuck',
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
  const [message, setMessage] = useState('')
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const phrase = useRotatingPhrase(ROTATING_PHRASES)
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
        <h3>Feeling Stuck?</h3>
        <p className="chat-start-description">
          Ask our Assistant about{' '}
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
            placeholder="Tell us what you're stuck on, and what you've already tried…"
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
            Ask our Assistant
          </button>
        </div>

        <p className="chat-start-included">
          <GraphicalIcon icon="check-circle" />
          <span>
            {insider
              ? 'Unlimited conversations, included with Insiders'
              : 'Get assistant help on this exercise - 100% free.'}
          </span>
        </p>
      </div>
    </div>
  )
}
