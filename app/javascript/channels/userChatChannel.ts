import consumer from '../utils/action-cable-consumer'

export class UserChatChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: (response: { text: string }) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'UserChatChannel',
      },
      {
        received: (response: { text: string }) => {
          onReceive(response)
        },
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
