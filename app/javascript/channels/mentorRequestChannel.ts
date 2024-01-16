import consumer from '../utils/action-cable-consumer'
import { MentorSessionRequest } from '../components/types'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'

export type ChannelResponse = {
  mentorRequest: {
    uuid: string
    status: 'cancelled' | 'pending' | 'fulfilled'
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
          onReceive(camelizeKeysAs<ChannelResponse>(response))
        },
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
