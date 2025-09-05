import consumer from '../utils/action-cable-consumer'

export type ChannelResponse = {
  key: string
  locale: string
  value: string
}

export class LocalizationTranslationChannel {
  subscription: ActionCable.Channel

  constructor(locale: string, onReceive: (response: ChannelResponse) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: `LocalizationTranslationChannel`,
        locale: locale,
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
