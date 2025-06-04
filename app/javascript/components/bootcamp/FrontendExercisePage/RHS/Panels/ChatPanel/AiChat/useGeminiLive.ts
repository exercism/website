export const API_KEY = ''

import { useEffect, useRef, useState } from 'react'
import { GoogleGenAI, Modality } from '@google/genai'

export function useGeminiLive(apiKey: string) {
  const responseQueue = useRef<any[]>([])
  const [session, setSession] = useState<any>(null)

  useEffect(() => {
    const ai = new GoogleGenAI({ apiKey })
    let connected = true

    async function connect() {
      const s = await ai.live.connect({
        model: 'gemini-2.0-flash-live-001',
        config: { responseModalities: [Modality.TEXT] },
        callbacks: {
          onopen: () => console.debug('Session opened'),
          onmessage: (message) => responseQueue.current.push(message),
          onerror: (e) => console.error('Session error:', e),
          onclose: (e) => console.debug('Session closed:', e.reason),
        },
      })

      if (connected) setSession(s)
    }

    connect()
    return () => {
      connected = false
      session?.close()
    }
  }, [apiKey])

  const sendMessage = (input: string) => {
    session?.sendClientContent({ turns: input })
  }

  const getNextTurn = async () => {
    const turns: any[] = []
    while (true) {
      const message = await waitMessage()
      turns.push(message)
      if (message.serverContent?.turnComplete) break
    }
    return turns
  }

  const waitMessage = async () => {
    while (responseQueue.current.length === 0) {
      await new Promise((resolve) => setTimeout(resolve, 100))
    }
    return responseQueue.current.shift()
  }

  return { sendMessage, getNextTurn, session }
}
