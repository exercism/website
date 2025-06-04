import React, { createContext, useRef } from 'react'
import { ChatInput } from './ChatInput'
import { ChatThread } from './ChatThread'

type ChatContextType = {
  inputRef: React.RefObject<HTMLTextAreaElement>
  scrollContainerRef: React.RefObject<HTMLDivElement>
  analyserRef: React.MutableRefObject<AnalyserNode | null>
}

export const ChatContext = createContext<ChatContextType>({
  inputRef: {} as ChatContextType['inputRef'],
  scrollContainerRef: {} as ChatContextType['scrollContainerRef'],
  analyserRef: {} as ChatContextType['analyserRef'],
})

export function Chat() {
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const analyserRef = useRef<AnalyserNode | null>(null)

  return (
    <ChatContext.Provider value={{ inputRef, scrollContainerRef, analyserRef }}>
      <div className="ai-chat-container">
        <ChatThread />
        <ChatInput />
      </div>
    </ChatContext.Provider>
  )
}
