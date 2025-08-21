import consumer from '../utils/action-cable-consumer'

const CHANNEL = 'ReputationChannel'

export class ReputationChannel {
  subscription: ActionCable.Channel | null = null
  private identifier: string

  constructor(onReceive: () => void) {
    this.identifier = JSON.stringify({ channel: CHANNEL })

    try {
      if (!this.isConsumerReady()) {
        console.error(`Consumer subscriptions not available for ${CHANNEL}`)
        return
      }

      const subscriptions = this.getSubscriptions()
      const existing = subscriptions.find(
        (sub: any) => sub?.identifier === this.identifier
      )

      if (existing) {
        console.warn(`Already subscribed to ${CHANNEL}`)
        this.subscription = existing
      } else {
        this.subscription = consumer.subscriptions.create(
          { channel: CHANNEL },
          { received: onReceive }
        )
      }
    } catch (error) {
      console.error(`Error creating ${CHANNEL} subscription:`, error)
      this.subscription = null
    }
  }

  disconnect(): void {
    try {
      if (!this.subscription) {
        console.warn(`No ${CHANNEL} subscription to disconnect`)
        return
      }

      if (!this.isConsumerReady()) {
        console.warn('Consumer subscriptions not available for disconnect')
        return
      }

      const subscriptions = this.getSubscriptions()
      const current = subscriptions.find(
        (sub: any) => sub?.identifier === this.identifier
      )

      if (current === this.subscription && this.subscription.unsubscribe) {
        this.subscription.unsubscribe()
      } else {
        console.warn('Unable to unsubscribe properly')
      }
    } catch (error) {
      console.error(`Error disconnecting ${CHANNEL}:`, error)
    } finally {
      this.subscription = null
    }
  }

  isConnected(): boolean {
    return this.subscription !== null
  }

  private isConsumerReady(): boolean {
    return !!(
      consumer?.subscriptions?.subscriptions && consumer.subscriptions?.create
    )
  }

  private getSubscriptions(): any[] {
    return consumer.subscriptions?.subscriptions || []
  }
}
