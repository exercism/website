import { useEffect, useRef, useState } from 'react'
import { GoogleGenAI, Modality } from '@google/genai'
import { mergeInt16Arrays, encodeWAV } from './utils'

type ResponseTurn =
  | { type: 'text'; text: string }
  | { type: 'audio'; audioBlob: Blob }

export function useGeminiLive({
  apiKey,
  responseModality,
}: {
  apiKey: string
  responseModality: Modality
}) {
  const responseQueue = useRef<any[]>([])
  const [session, setSession] = useState<any>(null)

  useEffect(() => {
    const ai = new GoogleGenAI({ apiKey })
    let connected = true

    async function connect() {
      const s = await ai.live.connect({
        model: 'gemini-2.0-flash-live-001',
        config: { responseModalities: [responseModality] },
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
  }, [apiKey, responseModality])

  const sendText = (text: string) => {
    session?.sendClientContent({ turns: text })
  }

  const sendAudio = (base64: string, sampleRate = 16000) => {
    session?.sendRealtimeInput({
      audio: {
        data: base64,
        mimeType: `audio/pcm;rate=${sampleRate}`,
      },
    })
  }

  const getNextTurn = async (): Promise<ResponseTurn[]> => {
    const turns: ResponseTurn[] = []
    const audioChunks: Int16Array[] = []

    while (true) {
      const message = await waitMessage()

      if (message.text) {
        turns.push({ type: 'text', text: message.text })
      }

      if (message.data) {
        const buffer = Uint8Array.from(atob(message.data), (c) =>
          c.charCodeAt(0)
        )
        const int16 = new Int16Array(buffer.buffer)
        audioChunks.push(int16)
      }

      if (message.serverContent?.turnComplete) break
    }

    if (audioChunks.length > 0) {
      const audioBlob = new Blob(
        [encodeWAV(mergeInt16Arrays(audioChunks), 24000)],
        {
          type: 'audio/wav',
        }
      )
      turns.push({ type: 'audio', audioBlob })
    }

    return turns
  }

  const waitMessage = async () => {
    while (responseQueue.current.length === 0) {
      await new Promise((resolve) => setTimeout(resolve, 100))
    }
    return responseQueue.current.shift()
  }

  return {
    sendText,
    sendAudio,
    getNextTurn,
    session,
  }
}
