import consumer from '../utils/action-cable-consumer'

export class BootcampChatChannel {
  subscription: ActionCable.Channel

  constructor(solutionUuid, onReceive: (response: { text: string }) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'BootcampChatChannel',
        solution_uuid: solutionUuid,
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
