import { BootcampChatChannel as BootcampChatChannel } from '@/channels/userBootcampChatChannel'
import { useEffect } from 'react'

export function useAiStream(
  solutionUuid: string,
  onMessageStream: (message: string) => void
) {
  useEffect(() => {
    const userChatChannel = new BootcampChatChannel(solutionUuid, (res) => {
      onMessageStream(res.text)

      console.log('RES', res)
    })
    return () => {
      userChatChannel.disconnect()
    }
  }, [])
}
