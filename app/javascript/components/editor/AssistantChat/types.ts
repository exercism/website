// Max characters for a single outgoing chat message (the user's question and
// each history entry). Mirrors the proxy's MAX_QUESTION_CHARS. Enforced in the
// composer UI AND again at the API boundary, so tampering with the textarea's
// maxLength in DevTools can't push an oversized payload over the wire.
export const MAX_CHAT_MESSAGE_LENGTH = 1000

export interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
  timestamp?: string
}

export interface SignatureData {
  type: 'signature'
  signature: string
  timestamp: string
  solutionUuid: string
  userMessage: string
  messagesToday?: number
  messagesThisMonth?: number
  dailyLimit?: number
  monthlyLimit?: number
}

// The user's current message usage, as reported by the LLM proxy. Counts are
// UTC-bucketed and include the message that was just served (post-increment).
export interface UsageMeta {
  messagesToday: number
  messagesThisMonth: number
  dailyLimit: number
  monthlyLimit: number
}

export interface ErrorData {
  type: 'error'
  error: string
  message: string
}

export type StreamStatus = 'idle' | 'thinking' | 'streaming' | 'error'

export interface AssistantChatLinks {
  createToken: string
  userMessages: string
  assistantMessages: string
}

// Server-rendered config for the assistant chat, from ReactComponents::Editor.
export interface AssistantChatConfig {
  chatUrl: string | null
  turnstileSiteKey: string
  allowed: boolean
  messages: ChatMessage[]
  links: AssistantChatLinks
}
