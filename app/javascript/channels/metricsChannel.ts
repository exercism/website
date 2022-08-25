import consumer from '../utils/action-cable-consumer'

export type MetricsChannelResponse = {
  metric: Metric
}

export class MetricsChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: () => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'MetricsChannel',
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
