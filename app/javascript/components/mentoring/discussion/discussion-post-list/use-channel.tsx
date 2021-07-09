import { useEffect } from 'react'
import { DiscussionPostChannel } from '../../../../channels/discussionPostChannel'

export const useChannel = (
  discussionUuid: string,
  onReceive: () => void
): void => {
  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionUuid: discussionUuid },
      onReceive
    )

    return () => {
      channel.disconnect()
    }
  }, [discussionUuid, onReceive])
}
