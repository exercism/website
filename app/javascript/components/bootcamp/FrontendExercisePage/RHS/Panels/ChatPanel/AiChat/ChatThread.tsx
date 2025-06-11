import React, { useContext, useEffect } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { useAiChatStore } from './store/aiChatStore'
import { useContinuousHighlighting } from '@/hooks/use-syntax-highlighting'
import { marked } from 'marked'

const MESSAGE_LABELS = {
  user: 'You',
  llm: 'AI Assistant',
}

export function ChatThread() {
  const { messages, messageStream } = useAiChatStore()
  const { scrollContainerRef } = useContext(ChatContext)

  useEffect(() => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollTo({
        top: scrollContainerRef.current.scrollHeight,
        behavior: 'smooth',
      })
    }
  }, [messages])

  const parentRef = useContinuousHighlighting<HTMLDivElement>(messageStream)
  // @ts-ignore
  const threadElementRef = useContinuousHighlighting<HTMLDivElement>(messages)

  return (
    <div className="chat-thread" ref={scrollContainerRef}>
      {messages.map((message, index) => {
        return (
          <div
            className={assembleClassNames(
              'chat-message-wrapper',
              message.author
            )}
            key={message.id + index}
          >
            {messages[index - 1] &&
              messages[index - 1]['author'] !== message.author && (
                <label>{MESSAGE_LABELS[message.author]}</label>
              )}
            <div
              ref={threadElementRef}
              className={assembleClassNames('chat-message', message.author)}
            >
              {message.content && (
                <div
                  dangerouslySetInnerHTML={{
                    __html: marked.parse(message.content),
                  }}
                />
              )}
            </div>
          </div>
        )
      })}

      {messageStream.length > 0 && (
        <div
          ref={parentRef}
          className="chat-message c-textual-content llm"
          dangerouslySetInnerHTML={{ __html: marked.parse(messageStream) }}
        />
      )}
    </div>
  )
}
