import React, { createContext, useEffect, useRef } from 'react'
import { ChatInput } from './ChatInput'
import { ChatThread } from './ChatThread'
import { useAiChatStore } from './store/aiChatStore'

type ChatContextType = {
  inputRef: React.RefObject<HTMLTextAreaElement>
  scrollContainerRef: React.RefObject<HTMLDivElement>
  analyserRef: React.MutableRefObject<AnalyserNode | null>
  links: { apiBootcampSolutionChat: string }
  solutionUuid: string
}

export const ChatContext = createContext<ChatContextType>({
  inputRef: {} as ChatContextType['inputRef'],
  scrollContainerRef: {} as ChatContextType['scrollContainerRef'],
  analyserRef: {} as ChatContextType['analyserRef'],
  links: { apiBootcampSolutionChat: '' },
  solutionUuid: '',
})

export function Chat({
  links,
  solutionUuid,
  messages,
}: {
  links: { apiBootcampSolutionChat: string }
  solutionUuid: string
  messages: Message[]
}) {
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const analyserRef = useRef<AnalyserNode | null>(null)

  const { appendMessage } = useAiChatStore()

  useEffect(() => {
    console.log('MESSAGES', messages)
    for (const message of messages) {
      appendMessage(message)
    }
  }, [])

  return (
    <ChatContext.Provider
      value={{
        inputRef,
        scrollContainerRef,
        analyserRef,
        links,
        solutionUuid,
      }}
    >
      <div className="ai-chat-container">
        <ChatThread />
        <ChatInput />
      </div>
    </ChatContext.Provider>
  )
}
