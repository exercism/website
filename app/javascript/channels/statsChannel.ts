import consumer from '../utils/action-cable-consumer'

export class StatsChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: () => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'StatsChannel',
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
