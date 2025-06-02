import { create } from 'zustand'

type AiChatStore = {
  messages: string[]
  appendMessage: (message: string) => void
}

export const useAiChatStore = create<AiChatStore>((set, get) => ({
  messages: [],
  appendMessage: (message: string) => {
    set((state) => ({
      messages: [...state.messages, message],
    }))
  },
}))
