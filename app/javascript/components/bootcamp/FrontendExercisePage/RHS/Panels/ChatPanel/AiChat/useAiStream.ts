import { UserChatChannel } from '@/channels/userChatChannel'
import { useEffect } from 'react'

export function useAiStream(onMessageStream: (message: string) => void) {
  useEffect(() => {
    const userChatChannel = new UserChatChannel((res) => {
      onMessageStream(res.text)

      console.log('RES', res)
    })
    return () => {
      userChatChannel.disconnect()
    }
  }, [])
}
