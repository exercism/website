import consumer from '../utils/action-cable-consumer'

export class ReputationChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: () => void) {
    const identifier = JSON.stringify({ channel: 'ReputationChannel' })

    const existing = consumer.subscriptions.subscriptions.find(
      (sub: any) => sub.identifier === identifier
    )

    if (existing) {
      console.warn('Already subscribed to ReputationChannel')
      this.subscription = existing
    } else {
      this.subscription = consumer.subscriptions.create(
        { channel: 'ReputationChannel' },
        {
          received: onReceive,
        }
      )
    }
  }

  disconnect(): void {
    const identifier = JSON.stringify({ channel: 'ReputationChannel' })
    const current = consumer.subscriptions.subscriptions.find(
      (sub: any) => sub.identifier === identifier
    )

    if (current === this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}
