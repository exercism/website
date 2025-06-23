import { create } from 'zustand'

export type AppendedMessage = Message | Omit<Message, 'id'>
type AiChatStore = {
  messages: Message[]
  appendMessage: (message: AppendedMessage) => void
  messageStream: string
  streamMessage: (message: string) => void
  finishStream: (audioBlob?: Blob) => void
  isMessageBeingStreamed: boolean
  isResponseBeingGenerated: boolean
  setIsResponseBeingGenerated: (isGenerating: boolean) => void
  scrollBehaviour: 'instant' | 'smooth'
  setScrollBehaviour: (behaviour: 'instant' | 'smooth') => void
}

const MOCK_MESSAGES: Message[] = [
  {
    id: 1,
    author: 'llm',
    content: 'Hello! How can I assist you today?',
  },
  {
    id: 2,
    author: 'user',
    content: 'Can you help me with my coding problem?',
  },
  {
    id: 3,
    author: 'llm',
    content: 'Sure! Please describe your problem in detail.',
  },
]

export const useAiChatStore = create<AiChatStore>((set, get) => ({
  messages: MOCK_MESSAGES,
  appendMessage: (message: AppendedMessage) => {
    set((state) => {
      const lastId =
        state.messages.length > 0
          ? state.messages[state.messages.length - 1].id
          : 0
      return {
        messages: [...state.messages, { ...message, id: lastId + 1 }],
      }
    })
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

    const messages = get().messages
    const lastId = messages.length > 0 ? messages[messages.length - 1].id : 0
    const newMessage: Message = {
      id: lastId + 1,
      author: 'llm',
      content: hasText ? messageStream : '',
    }
    appendMessage(newMessage)
    set({
      messageStream: '',
      isMessageBeingStreamed: false,
      isResponseBeingGenerated: false,
    })
  },
  scrollBehaviour: 'instant',
  setScrollBehaviour: (behaviour: 'instant' | 'smooth') => {
    set({ scrollBehaviour: behaviour })
  },
}))
