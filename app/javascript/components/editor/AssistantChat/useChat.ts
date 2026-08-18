import { useCallback, useEffect, useRef } from 'react'
import type { File } from '../../types'
import type { AssistantChatConfig } from './types'
import { useChatState } from './useChatState'
import { useTurnstile } from './useTurnstile'
import {
  sendChatMessage,
  ChatTokenExpiredError,
  ChatUsageLimitError,
  ChatRateLimitedError,
} from './chatApi'
import {
  fetchChatToken,
  ChatTokenAccessDeniedError,
  ChatTokenInvalidCaptchaError,
} from './chatTokenApi'
import { saveConversation } from './conversationApi'
import { extractUsage } from './chatUsage'

export function useChat(
  config: AssistantChatConfig,
  solutionUuid: string,
  getFiles: () => File[]
) {
  const chatState = useChatState()
  const turnstile = useTurnstile(config.turnstileSiteKey)
  const tokenFetchInProgress = useRef<Promise<string> | null>(null)
  const loadedRef = useRef(false)

  // Seed the conversation with the server-rendered history.
  useEffect(() => {
    if (loadedRef.current) return
    loadedRef.current = true
    if (config.messages.length > 0) {
      chatState.loadConversation(config.messages)
    }
  }, [chatState, config.messages])

  // Get existing token or fetch a new one. One Turnstile pass per chat
  // session - once we hold a chat token, subsequent messages reuse it.
  const ensureValidToken = useCallback(async (): Promise<string> => {
    if (chatState.chatToken) {
      return chatState.chatToken
    }

    if (tokenFetchInProgress.current) {
      return tokenFetchInProgress.current
    }

    tokenFetchInProgress.current = (async () => {
      const cfTurnstileResponse = await turnstile.execute()
      return fetchChatToken(config.links.createToken, cfTurnstileResponse)
    })()

    try {
      const token = await tokenFetchInProgress.current
      chatState.setChatToken(token)
      return token
    } finally {
      tokenFetchInProgress.current = null
    }
  }, [chatState, config.links.createToken, turnstile])

  const performChatRequest = useCallback(
    async (message: string, token: string) => {
      if (!config.chatUrl) {
        throw new Error('Assistant chat is not configured')
      }

      // Read the editor contents lazily, when the message is actually sent, so
      // the proxy receives the student's current code rather than a snapshot
      // taken at render time.
      const files = getFiles().map((file) => ({
        filename: file.filename,
        content: file.content,
      }))

      await sendChatMessage(
        config.chatUrl,
        {
          solutionUuid,
          files,
          question: message,
          history: chatState.messages,
        },
        {
          onTextChunk: (text) => {
            chatState.appendToCurrentResponse(text)
          },
          onSignature: (signature) => {
            chatState.setSignature(signature)
            // The proxy reports the user's current usage on the signature
            // event. Capturing it drives the "getting close" warning and
            // pre-empts the cap (disable the composer at the limit).
            const usage = extractUsage(signature)
            if (usage) {
              chatState.setUsage(usage)
            }
          },
          onError: (error) => {
            chatState.setError(error)
            chatState.setStatus('error')
          },
          onComplete: (fullResponse, signature) => {
            if (fullResponse.trim()) {
              if (signature) {
                chatState.setSignature(signature)
                saveConversation(
                  config.links,
                  message,
                  fullResponse,
                  signature
                ).catch((error: unknown) => {
                  console.error('Failed to save conversation:', error)
                })
              }
              chatState.finishResponse(fullResponse)
            } else {
              chatState.setStatus('idle')
            }
          },
        },
        token
      )
    },
    [chatState, config.chatUrl, config.links, getFiles, solutionUuid]
  )

  const sendMessage = useCallback(
    async (message: string) => {
      if (
        !message.trim() ||
        chatState.status === 'thinking' ||
        chatState.status === 'streaming'
      ) {
        return
      }

      chatState.addUserMessageImmediately(message)

      try {
        const token = await ensureValidToken()

        try {
          await performChatRequest(message, token)
        } catch (error) {
          // If token expired, clear it, get a new one, and retry once
          if (error instanceof ChatTokenExpiredError) {
            chatState.clearChatToken()
            const newToken = await ensureValidToken()
            await performChatRequest(message, newToken)
          } else {
            throw error
          }
        }
      } catch (error) {
        // The user spent their free conversation on another exercise (or lost
        // Insiders access). Show the upsell state instead of an error.
        if (error instanceof ChatTokenAccessDeniedError) {
          chatState.rollbackToBeforeLastUserMessage()
          chatState.setAccessDenied()
          return
        }

        if (error instanceof ChatTokenInvalidCaptchaError) {
          chatState.setError('Verification failed, please try again.')
          chatState.setStatus('error')
          return
        }

        // Quota cap: record the usage so the composer disables and shows the
        // cap notice. No error/retry - the cap won't recover until reset.
        if (error instanceof ChatUsageLimitError) {
          chatState.rollbackToBeforeLastUserMessage()
          chatState.setUsage(error.usage)
          chatState.setStatus('idle')
          return
        }

        if (error instanceof ChatRateLimitedError) {
          chatState.setError(error.message)
          chatState.setStatus('error')
          return
        }

        const errorMessage =
          error instanceof Error ? error.message : 'Something went wrong'
        chatState.setError(errorMessage)
        chatState.setStatus('error')
      }
    },
    [chatState, ensureValidToken, performChatRequest]
  )

  const retryLastMessage = useCallback(() => {
    if (chatState.status !== 'error' || chatState.messages.length === 0) return

    const lastUserMessage = [...chatState.messages]
      .reverse()
      .find((message) => message.role === 'user')
    if (!lastUserMessage) return

    chatState.rollbackToBeforeLastUserMessage()
    chatState.setError(null)
    chatState.setStatus('idle')
    void sendMessage(lastUserMessage.content)
  }, [chatState, sendMessage])

  return {
    ...chatState,
    sendMessage,
    retryLastMessage,
    isDisabled:
      chatState.status === 'thinking' || chatState.status === 'streaming',
    canRetry: chatState.status === 'error' && chatState.messages.length > 0,
  }
}
