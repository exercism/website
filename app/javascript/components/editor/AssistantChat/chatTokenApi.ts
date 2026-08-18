export class ChatTokenError extends Error {
  constructor(message: string, public status?: number, public data?: unknown) {
    super(message)
    this.name = 'ChatTokenError'
  }
}

// 403 with error.type === "assistant_conversation_not_accessible": the user
// has spent their free conversation and isn't an Insider. Distinct from
// ChatTokenInvalidCaptchaError so the UI can branch (upsell vs infra error).
export class ChatTokenAccessDeniedError extends ChatTokenError {
  constructor(message: string, data?: unknown) {
    super(message, 403, data)
    this.name = 'ChatTokenAccessDeniedError'
  }
}

// 403 with error.type === "invalid_captcha": Cloudflare Turnstile token
// failed verification. Infra failure, not a product event.
export class ChatTokenInvalidCaptchaError extends ChatTokenError {
  constructor(message: string, data?: unknown) {
    super(message, 403, data)
    this.name = 'ChatTokenInvalidCaptchaError'
  }
}

export async function fetchChatToken(
  endpoint: string,
  cfTurnstileResponse: string
): Promise<string> {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ cf_turnstile_response: cfTurnstileResponse }),
  })

  if (!response.ok) {
    const errorData = await parseErrorBody(response)

    if (response.status === 403) {
      const errorType = extractErrorType(errorData)
      const message =
        extractErrorMessage(errorData) ?? `HTTP 403: ${response.statusText}`
      if (errorType === 'assistant_conversation_not_accessible') {
        throw new ChatTokenAccessDeniedError(message, errorData)
      }
      if (errorType === 'invalid_captcha') {
        throw new ChatTokenInvalidCaptchaError(message, errorData)
      }
    }

    throw new ChatTokenError(
      `HTTP ${response.status}: ${response.statusText}`,
      response.status,
      errorData
    )
  }

  const data = (await response.json()) as { token: string }
  return data.token
}

async function parseErrorBody(response: Response): Promise<unknown> {
  try {
    const contentType = response.headers.get('content-type')
    if (contentType?.includes('application/json')) {
      return await response.json()
    }
    return await response.text()
  } catch {
    return { error: 'unknown', message: 'Failed to parse error response' }
  }
}

export function extractErrorType(data: unknown): string | undefined {
  if (typeof data !== 'object' || data === null) return undefined
  const errorField = (data as { error?: unknown }).error
  if (typeof errorField !== 'object' || errorField === null) return undefined
  const type = (errorField as { type?: unknown }).type
  return typeof type === 'string' ? type : undefined
}

export function extractErrorMessage(data: unknown): string | undefined {
  if (typeof data !== 'object' || data === null) return undefined
  const errorField = (data as { error?: unknown }).error
  if (typeof errorField !== 'object' || errorField === null) return undefined
  const message = (errorField as { message?: unknown }).message
  return typeof message === 'string' ? message : undefined
}
