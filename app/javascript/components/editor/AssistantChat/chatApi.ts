import { MAX_CHAT_MESSAGE_LENGTH } from './types'
import type { ChatMessage, SignatureData, ErrorData, UsageMeta } from './types'

export type UsageScope = 'daily' | 'monthly'

export interface ChatRequestPayload {
  solutionUuid: string
  files: { filename: string; content: string }[]
  question: string
  history: ChatMessage[]
}

export interface StreamCallbacks {
  onTextChunk: (text: string) => void
  onSignature: (signature: SignatureData) => void
  onError: (error: string) => void
  onComplete: (fullResponse: string, signature: SignatureData | null) => void
}

export class ChatApiError extends Error {
  constructor(message: string, public status?: number, public data?: unknown) {
    super(message)
    this.name = 'ChatApiError'
  }
}

export class ChatTokenExpiredError extends Error {
  constructor(message = 'Chat token expired') {
    super(message)
    this.name = 'ChatTokenExpiredError'
  }
}

// 429 usage_limit_reached: the user has hit their daily or monthly quota. This
// is terminal until the relevant reset, so it must NOT be auto-retried.
export class ChatUsageLimitError extends Error {
  constructor(public scope: UsageScope, public usage: UsageMeta) {
    super('usage_limit_reached')
    this.name = 'ChatUsageLimitError'
  }
}

// 429 rate_limited: short burst throttle. Transient — the user can try again
// shortly, but we don't auto-retry (that would just hammer the throttle).
export class ChatRateLimitedError extends Error {
  constructor(
    message = 'Too many requests. Please wait a moment and try again.'
  ) {
    super(message)
    this.name = 'ChatRateLimitedError'
  }
}

export async function sendChatMessage(
  chatUrl: string,
  payload: ChatRequestPayload,
  callbacks: StreamCallbacks,
  chatToken: string
): Promise<void> {
  // Enforce limits again at the API boundary - the composer's maxLength is
  // client-side only, and there's no point sending oversized payloads the
  // proxy will just crop/reject anyway.
  const truncatedPayload = {
    ...payload,
    question: payload.question.slice(0, MAX_CHAT_MESSAGE_LENGTH),
    history: payload.history.slice(-10).map((message) => ({
      role: message.role,
      content: message.content.slice(0, MAX_CHAT_MESSAGE_LENGTH),
    })),
  }

  await performChatRequest(chatUrl, truncatedPayload, callbacks, chatToken)
}

async function performChatRequest(
  chatUrl: string,
  payload: ChatRequestPayload,
  callbacks: StreamCallbacks,
  chatToken: string
): Promise<void> {
  try {
    const response = await fetch(`${chatUrl}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${chatToken}`,
      },
      body: JSON.stringify(payload),
    })

    if (!response.ok) {
      let errorData: unknown
      try {
        const contentType = response.headers.get('content-type')
        if (contentType?.includes('application/json')) {
          errorData = await response.json()
        } else {
          errorData = await response.text()
        }
      } catch {
        errorData = {
          error: 'unknown',
          message: 'Failed to parse error response',
        }
      }

      // token_expired: let the caller refresh the token and retry
      if (
        response.status === 401 &&
        errorData &&
        typeof errorData === 'object'
      ) {
        const errorObj = errorData as Record<string, unknown>
        if (errorObj.error === 'token_expired') {
          throw new ChatTokenExpiredError()
        }
      }

      // 429s come in two flavours, distinguished by the `error` field: a quota
      // cap (usage_limit_reached) versus a transient burst throttle
      // (rate_limited). Surface them as distinct typed errors.
      if (
        response.status === 429 &&
        errorData &&
        typeof errorData === 'object'
      ) {
        const errorObj = errorData as Record<string, unknown>
        if (errorObj.error === 'usage_limit_reached') {
          const scope: UsageScope =
            errorObj.scope === 'monthly' ? 'monthly' : 'daily'
          throw new ChatUsageLimitError(scope, {
            messagesToday: Number(errorObj.messagesToday),
            messagesThisMonth: Number(errorObj.messagesThisMonth),
            dailyLimit: Number(errorObj.dailyLimit),
            monthlyLimit: Number(errorObj.monthlyLimit),
          })
        }
        if (errorObj.error === 'rate_limited') {
          throw new ChatRateLimitedError(
            typeof errorObj.message === 'string' ? errorObj.message : undefined
          )
        }
      }

      throw new ChatApiError(
        `HTTP ${response.status}: ${response.statusText}`,
        response.status,
        errorData
      )
    }

    if (!response.body) {
      throw new ChatApiError('No response body received')
    }

    await handleStreamingResponse(response.body, callbacks)
  } catch (error) {
    if (
      error instanceof ChatApiError ||
      error instanceof ChatTokenExpiredError ||
      error instanceof ChatUsageLimitError ||
      error instanceof ChatRateLimitedError
    ) {
      throw error
    }
    const message = error instanceof Error ? error.message : 'Unknown error'
    throw new ChatApiError(message)
  }
}

// The proxy's stream is hybrid: raw text chunks (the response itself)
// interleaved with SSE-framed `data: {json}` lines used only for the terminal
// signature/error events.
async function handleStreamingResponse(
  body: ReadableStream<Uint8Array>,
  callbacks: StreamCallbacks
): Promise<void> {
  const reader = body.getReader()
  const decoder = new TextDecoder()
  let accumulatedText = ''
  let buffer = ''
  let receivedSignature: SignatureData | null = null

  try {
    while (true) {
      const { done, value } = await reader.read()

      if (done) {
        break
      }

      const chunk = decoder.decode(value, { stream: true })
      buffer += chunk

      // Check for "data: " markers in the buffer
      let dataIndex = buffer.indexOf('data: ')

      while (dataIndex !== -1) {
        // If there's text before "data: ", it's part of the response
        if (dataIndex > 0) {
          const textBeforeData = buffer.substring(0, dataIndex)
          accumulatedText += textBeforeData
          callbacks.onTextChunk(textBeforeData)
        }

        // Find the end of this data line (look for next newline)
        const endOfLine = buffer.indexOf('\n', dataIndex)
        if (endOfLine === -1) {
          // Incomplete data line, keep in buffer
          buffer = buffer.substring(dataIndex)
          break
        }

        // Extract the data line (+6 to skip "data: ")
        const dataLine = buffer.substring(dataIndex + 6, endOfLine)

        try {
          const data = JSON.parse(dataLine)

          if (data.type === 'signature') {
            receivedSignature = data as SignatureData
            callbacks.onSignature(receivedSignature)
          } else if (data.type === 'error') {
            const errorData = data as ErrorData
            callbacks.onError(errorData.message)
            return
          }
        } catch {
          console.error('Failed to parse SSE data:', dataLine)
        }

        // Move past this data line
        buffer = buffer.substring(endOfLine + 1)
        dataIndex = buffer.indexOf('data: ')
      }

      // Any remaining buffer is text
      if (buffer && !buffer.startsWith('data: ')) {
        const lines = buffer.split('\n')
        buffer = lines.pop() || ''
        for (const line of lines) {
          const lineWithNewline = line + '\n'
          accumulatedText += lineWithNewline
          callbacks.onTextChunk(lineWithNewline)
        }
      }
    }

    // Process any remaining buffer
    if (buffer.trim()) {
      accumulatedText += buffer
      callbacks.onTextChunk(buffer)
    }

    callbacks.onComplete(accumulatedText.trim(), receivedSignature)
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Stream processing error'
    callbacks.onError(message)
    throw new ChatApiError(message)
  }
}
