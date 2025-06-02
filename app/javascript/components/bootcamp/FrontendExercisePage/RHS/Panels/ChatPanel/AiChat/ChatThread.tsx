import React, { useContext, useEffect } from 'react'
import { useAiChatStore } from './store/AiChatStore'
import { ChatContext } from '.'

export function ChatThread() {
  const { messages } = useAiChatStore()
  const { scrollContainerRef } = useContext(ChatContext)

  useEffect(() => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollTo({
        top: scrollContainerRef.current.scrollHeight,
        behavior: 'smooth',
      })
    }
  }, [messages])

  return (
    <div className="chat-thread" ref={scrollContainerRef}>
      {messages.map((message, index) => (
        <div key={index} className="chat-message">
          {message}
        </div>
      ))}
    </div>
  )
}
