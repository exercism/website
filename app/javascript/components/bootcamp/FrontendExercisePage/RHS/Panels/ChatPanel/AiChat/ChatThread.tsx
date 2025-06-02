import React, { useContext, useEffect } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { useAiChatStore } from './store/aiChatStore'
import { FAKE_LONG_STREAM_MESSAGE } from './ChatInput'
import { useContinuousHighlighting } from '@/hooks/use-syntax-highlighting'

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
            ref={threadElementRef}
            key={message.id + index}
            className={assembleClassNames('chat-message', message.sender)}
            dangerouslySetInnerHTML={{ __html: message.content }}
          />
        )
      })}

      {messageStream.length > 0 && (
        <div
          ref={parentRef}
          className="chat-message ai"
          dangerouslySetInnerHTML={{ __html: messageStream }}
        />
      )}
    </div>
  )
}
