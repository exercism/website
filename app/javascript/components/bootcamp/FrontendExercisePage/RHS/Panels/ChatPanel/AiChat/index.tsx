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
  code: Partial<Code>
}

export type Code = {
  html: string
  css: string
  js: string
  jiki: string
}

export const ChatContext = createContext<ChatContextType>({
  inputRef: {} as ChatContextType['inputRef'],
  scrollContainerRef: {} as ChatContextType['scrollContainerRef'],
  analyserRef: {} as ChatContextType['analyserRef'],
  links: { apiBootcampSolutionChat: '' },
  solutionUuid: '',
  code: {} as Code,
})

export function Chat({
  links,
  solutionUuid,
  messages,
  code,
}: {
  links: { apiBootcampSolutionChat: string }
  solutionUuid: string
  messages: Message[]
  code: Partial<Code>
}) {
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const analyserRef = useRef<AnalyserNode | null>(null)

  const { appendMessage } = useAiChatStore()

  // populates the message-thread
  const arePrevMessagesLoaded = useRef(false)

  useEffect(() => {
    if (!arePrevMessagesLoaded.current && messages && messages.length > 0) {
      for (const message of messages) {
        appendMessage(message)
      }
      arePrevMessagesLoaded.current = true
    }
  }, [messages])

  return (
    <ChatContext.Provider
      value={{
        inputRef,
        scrollContainerRef,
        analyserRef,
        links,
        solutionUuid,
        code,
      }}
    >
      <div className="ai-chat-container">
        <ChatThread />
        <ChatInput />
      </div>
    </ChatContext.Provider>
  )
}
