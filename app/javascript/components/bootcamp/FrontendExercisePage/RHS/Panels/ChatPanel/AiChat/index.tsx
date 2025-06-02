import React, { createContext, useCallback, useRef } from 'react'
import { ChatInput } from './ChatInput'
import { ChatThread } from './ChatThread'

type ChatContextType = {
  inputRef: React.RefObject<HTMLTextAreaElement>
  scrollContainerRef: React.RefObject<HTMLDivElement>
}

export const ChatContext = createContext<ChatContextType>({
  inputRef: {} as React.RefObject<HTMLTextAreaElement>,
  scrollContainerRef: {} as React.RefObject<HTMLDivElement>,
})
export function Chat() {
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)

  return (
    <ChatContext.Provider value={{ inputRef, scrollContainerRef }}>
      <div className="ai-chat-container">
        <ChatThread />
        <ChatInput />
      </div>
    </ChatContext.Provider>
  )
}
