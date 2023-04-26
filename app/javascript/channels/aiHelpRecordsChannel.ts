import consumer from '../utils/action-cable-consumer'

export type ChannelResponse = {
  help_record: {
    source: string
    advice_html: string
  }
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

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
