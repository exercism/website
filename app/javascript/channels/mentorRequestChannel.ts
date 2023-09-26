import consumer from '../utils/action-cable-consumer'
import { MentorSessionRequest } from '../components/types'

export type ChannelResponse = {
  uuid: string
  status: 'cancelled' | 'pending' | 'fulfilled'
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
