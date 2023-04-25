import consumer from '../utils/action-cable-consumer'
import { IterationStatus } from '../components/types'

export type ChannelResponse = {
  status: IterationStatus
}

export class AIHelpRecordsChannel {
  subscription: ActionCable.Channel

  constructor(
    submission_uuid: string,
    onReceive: (response: ChannelResponse) => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'AIHelpRecordsChannel',
        submission_uuid: submission_uuid,
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
