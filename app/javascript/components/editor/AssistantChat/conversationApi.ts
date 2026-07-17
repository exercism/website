import type { AssistantChatLinks, SignatureData } from './types'
import { extractErrorMessage, extractErrorType } from './chatTokenApi'

export class ConversationSaveError extends Error {
  constructor(message: string, public status?: number, public data?: unknown) {
    super(message)
    this.name = 'ConversationSaveError'
  }
}

// Persists a completed exchange to the website. The assistant message carries
// the proxy's HMAC signature, which Rails verifies before saving - so a
// message without a valid signature can't be persisted as "assistant".
export async function saveConversation(
  links: AssistantChatLinks,
  userMessage: string,
  assistantMessage: string,
  signature: SignatureData
): Promise<void> {
  await postMessage(links.userMessages, {
    content: userMessage,
    timestamp: new Date().toISOString(),
  })

  await postMessage(links.assistantMessages, {
    content: assistantMessage,
    timestamp: signature.timestamp,
    signature: signature.signature,
  })
}

async function postMessage(
  endpoint: string,
  payload: Record<string, string>
): Promise<void> {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(payload),
  })

  if (!response.ok) {
    let errorData: unknown
    try {
      errorData = await response.json()
    } catch {
      errorData = undefined
    }

    const message =
      extractErrorMessage(errorData) ??
      `Failed to save message: HTTP ${response.status}`
    throw new ConversationSaveError(
      `${message}${
        extractErrorType(errorData) ? ` (${extractErrorType(errorData)})` : ''
      }`,
      response.status,
      errorData
    )
  }
}
