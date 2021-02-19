import consumer from '../utils/action-cable-consumer'

export class ReputationChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: () => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'ReputationChannel',
      },
      {
        received: onReceive,
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
