import consumer from '../utils/action-cable-consumer'
import { IterationStatus } from '../components/types'

export type ChannelResponse = {
  status: IterationStatus
}

export class LatestIterationStatusChannel {
  subscription: ActionCable.Channel

  constructor(uuid: string, onReceive: (response: ChannelResponse) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'LatestIterationStatusChannel',
        uuid: uuid,
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
