import { create } from 'zustand'

type Message = {
  id: string
  sender: 'user' | 'ai'
  content: string
  timestamp: string
}

type AiChatStore = {
  messages: Message[]
  appendMessage: (message: Message) => void
  messageStream: string
  streamMessage: (message: string) => void
  finishStream: () => void
  isMessageBeingStreamed: boolean
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
  messageStream: '',
  streamMessage: (message: string) => {
    set((state) => ({
      isMessageBeingStreamed: true,
      messageStream: state.messageStream + message,
    }))
  },
  finishStream: () => {
    const { messageStream, appendMessage } = get()
    if (messageStream.trim() === '') return
    const newMessage: Message = {
      id: Date.now().toString(),
      sender: 'ai',
      content: messageStream,
      timestamp: new Date().toISOString(),
    }
    appendMessage(newMessage)
    set({ messageStream: '', isMessageBeingStreamed: false })
  },
}))
