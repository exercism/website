import { useState, useCallback } from 'react'
import type {
  ChatMessage,
  StreamStatus,
  SignatureData,
  UsageMeta,
} from './types'

export interface ChatState {
  messages: ChatMessage[]
  currentResponse: string
  status: StreamStatus
  error: string | null
  signature: SignatureData | null
  chatToken: string | null
  usage: UsageMeta | null
  // Set when the server rejects token minting with access_denied: the user
  // spent their free conversation elsewhere (e.g. in another tab).
  accessDenied: boolean
}

export function useChatState() {
  const [state, setState] = useState<ChatState>({
    messages: [],
    currentResponse: '',
    status: 'idle',
    error: null,
    signature: null,
    chatToken: null,
    usage: null,
    accessDenied: false,
  })

  const setStatus = useCallback((status: StreamStatus) => {
    setState((prev) => ({ ...prev, status }))
  }, [])

  const setError = useCallback((error: string | null) => {
    setState((prev) => ({ ...prev, error }))
  }, [])

  const appendToCurrentResponse = useCallback((chunk: string) => {
    setState((prev) => ({
      ...prev,
      currentResponse: prev.currentResponse + chunk,
      status: 'streaming',
    }))
  }, [])

  const setSignature = useCallback((signature: SignatureData | null) => {
    setState((prev) => ({ ...prev, signature }))
  }, [])

  const setChatToken = useCallback((chatToken: string) => {
    setState((prev) => ({ ...prev, chatToken }))
  }, [])

  // Usage reflects the user's quota, not the conversation, so it survives the
  // conversation-level resets below (which all spread `prev`).
  const setUsage = useCallback((usage: UsageMeta) => {
    setState((prev) => ({ ...prev, usage }))
  }, [])

  const setAccessDenied = useCallback(() => {
    setState((prev) => ({ ...prev, accessDenied: true, status: 'idle' }))
  }, [])

  const clearChatToken = useCallback(() => {
    setState((prev) => ({ ...prev, chatToken: null }))
  }, [])

  const addMessage = useCallback((message: ChatMessage) => {
    setState((prev) => ({
      ...prev,
      messages: [...prev.messages, message],
    }))
  }, [])

  // Moves the streamed response into the message list and resets for the
  // next exchange.
  const finishResponse = useCallback((fullResponse: string) => {
    setState((prev) => ({
      ...prev,
      messages: [
        ...prev.messages,
        { role: 'assistant', content: fullResponse },
      ],
      currentResponse: '',
      status: 'idle',
    }))
  }, [])

  const addUserMessageImmediately = useCallback((userMessage: string) => {
    setState((prev) => ({
      ...prev,
      messages: [...prev.messages, { role: 'user', content: userMessage }],
      currentResponse: '',
      error: null,
      signature: null,
      status: 'thinking',
    }))
  }, [])

  const loadConversation = useCallback((messages: ChatMessage[]) => {
    setState((prev) => ({
      ...prev,
      messages: [...messages],
      currentResponse: '',
      status: 'idle',
      error: null,
      signature: null,
    }))
  }, [])

  const rollbackToBeforeLastUserMessage = useCallback(() => {
    setState((prev) => {
      const lastUserIndex = prev.messages
        .map((message) => message.role)
        .lastIndexOf('user')
      return {
        ...prev,
        messages:
          lastUserIndex === -1
            ? prev.messages
            : prev.messages.slice(0, lastUserIndex),
        currentResponse: '',
      }
    })
  }, [])

  return {
    ...state,
    setStatus,
    setError,
    appendToCurrentResponse,
    setSignature,
    setChatToken,
    clearChatToken,
    setUsage,
    setAccessDenied,
    addMessage,
    finishResponse,
    addUserMessageImmediately,
    loadConversation,
    rollbackToBeforeLastUserMessage,
  }
}
