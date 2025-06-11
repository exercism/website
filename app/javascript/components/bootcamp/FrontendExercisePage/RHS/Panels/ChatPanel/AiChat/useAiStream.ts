import { BootcampChatChannel } from '@/channels/userBootcampChatChannel'
import { useEffect } from 'react'

export function useAiStream(
  solutionUuid: string,
  onNewMessage: (message: string) => void,
  onFinished: () => void
) {
  useEffect(() => {
    const userChatChannel = new BootcampChatChannel(solutionUuid, (res) => {
      console.log('RES', res)
      if (res.text) {
        onNewMessage(res.text)
      }
      if (res.done) {
        onFinished()
      }
    })
    return () => {
      userChatChannel.disconnect()
    }
  }, [])
}
