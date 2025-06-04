import { create } from 'zustand'

export type Message = {
  id: string
  sender: 'user' | 'ai'
  content: string
  audioUrl?: string
  timestamp: string
}

type AiChatStore = {
  messages: Message[]
  appendMessage: (message: Message) => void
  messageStream: string
  streamMessage: (message: string) => void
  finishStream: (audioBlob?: Blob) => void
  isMessageBeingStreamed: boolean
  isResponseBeingGenerated: boolean
  setIsResponseBeingGenerated: (isGenerating: boolean) => void
}

const MOCK_MESSAGES: Message[] = [
  {
    id: '1',
    sender: 'ai',
    content: 'Hello! How can I assist you today?',
    timestamp: new Date().toISOString(),
  },
  {
    id: '2',
    sender: 'user',
    content: 'Can you help me with my coding problem?',
    timestamp: new Date().toISOString(),
  },
  {
    id: '3',
    sender: 'ai',
    content: 'Sure! Please describe your problem in detail.',
    timestamp: new Date().toISOString(),
  },
]

export const useAiChatStore = create<AiChatStore>((set, get) => ({
  messages: MOCK_MESSAGES,
  appendMessage: (message: Message) => {
    set((state) => ({
      messages: [...state.messages, message],
    }))
  },
  isMessageBeingStreamed: false,
  isResponseBeingGenerated: false,
  setIsResponseBeingGenerated: (isGenerating: boolean) => {
    set({ isResponseBeingGenerated: isGenerating })
  },
  messageStream: '',
  streamMessage: (message: string) => {
    set((state) => ({
      isMessageBeingStreamed: true,
      isResponseBeingGenerated: false,
      messageStream: state.messageStream + message,
    }))
  },
  finishStream: (audioBlob?: Blob) => {
    const { messageStream, appendMessage } = get()

    const hasText = messageStream.trim() !== ''
    const hasAudio = !!audioBlob

    if (!hasText && !hasAudio) {
      set({
        messageStream: '',
        isMessageBeingStreamed: false,
        isResponseBeingGenerated: false,
      })
      return
    }

    const newMessage: Message = {
      id: Date.now().toString(),
      sender: 'ai',
      content: hasText ? messageStream : '',
      audioUrl: hasAudio ? URL.createObjectURL(audioBlob) : '',
      timestamp: new Date().toISOString(),
    }
    appendMessage(newMessage)
    set({
      messageStream: '',
      isMessageBeingStreamed: false,
      isResponseBeingGenerated: false,
    })
  },
}))
