import consumer from '../utils/action-cable-consumer'
import { MentorSessionRequest } from '../components/types'

export type ChannelResponse = {
  mentor_request: {
    uuid: string
    status: string
  }
}
export class MentorRequestChannel {
  subscription: ActionCable.Channel

  constructor(
    request: MentorSessionRequest,
    onReceive: (response: ChannelResponse) => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'MentorRequestChannel',
        uuid: request.uuid,
      },
      {
        received: (response: ChannelResponse) => {
          onReceive(response)
        },
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
