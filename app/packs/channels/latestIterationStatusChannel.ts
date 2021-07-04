import consumer from '../utils/action-cable-consumer'
import { IterationStatus } from '../components/types'

export type ChannelResponse = {
  status: IterationStatus
}

export class LatestIterationStatusChannel {
  subscription: ActionCable.Channel

  constructor(id: string, onReceive: (response: ChannelResponse) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'LatestIterationStatusChannel',
        id: id,
      },
      {
        received: (response: ChannelResponse) => {
          onReceive(response)
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
