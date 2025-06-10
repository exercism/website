import React, { createContext, useRef } from 'react'
import { ChatInput } from './ChatInput'
import { ChatThread } from './ChatThread'
import { useGeminiLive } from './useGeminiLive'
import { Modality } from '@google/genai'

const API_KEY = ''

type ChatContextType = {
  inputRef: React.RefObject<HTMLTextAreaElement>
  scrollContainerRef: React.RefObject<HTMLDivElement>
  analyserRef: React.MutableRefObject<AnalyserNode | null>
  geminiText: ReturnType<typeof useGeminiLive>
  geminiVoice: ReturnType<typeof useGeminiLive>
  links: { apiBootcampSolutionChat: string }
  solutionUuid: string
  userId: number
}

export const ChatContext = createContext<ChatContextType>({
  inputRef: {} as ChatContextType['inputRef'],
  scrollContainerRef: {} as ChatContextType['scrollContainerRef'],
  analyserRef: {} as ChatContextType['analyserRef'],
  geminiText: {} as ChatContextType['geminiText'],
  geminiVoice: {} as ChatContextType['geminiVoice'],
  links: { apiBootcampSolutionChat: '' },
  solutionUuid: '',
  userId: 0,
})

export function Chat({
  links,
  solutionUuid,
  userId,
}: {
  links: { apiBootcampSolutionChat: string }
  solutionUuid: string
  userId: number
}) {
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const analyserRef = useRef<AnalyserNode | null>(null)

  // const geminiText = useGeminiLive({
  //   apiKey: API_KEY,
  //   responseModality: Modality.TEXT,
  // })
  // const geminiVoice = useGeminiLive({
  //   apiKey: API_KEY,
  //   responseModality: Modality.AUDIO,
  // })

  return (
    <ChatContext.Provider
      value={{
        inputRef,
        scrollContainerRef,
        analyserRef,
        geminiText: null,
        geminiVoice: null,
        links,
        solutionUuid,
        userId,
      }}
    >
      <div className="ai-chat-container">
        <ChatThread />
        <ChatInput />
      </div>
    </ChatContext.Provider>
  )
}
