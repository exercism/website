import React, { useContext, useEffect } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { useAiChatStore } from './store/aiChatStore'
import { useContinuousHighlighting } from '@/hooks/use-syntax-highlighting'
import { marked } from 'marked'

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
            key={message.id + index}
            ref={threadElementRef}
            className={assembleClassNames(
              'chat-message c-textual-content',
              message.author
            )}
          >
            {message.content && (
              <div
                dangerouslySetInnerHTML={{
                  __html: marked.parse(message.content),
                }}
              />
            )}

            {/* {message.audioUrl && (
              <audio
                controls
                src={message.audioUrl}
                className="h-32 w-[300px]"
              />
            )} */}
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
