import consumer from '../utils/action-cable-consumer'

export type Response = {
  text: string | null
  done: boolean
}

export class BootcampChatChannel {
  subscription: ActionCable.Channel

  constructor(solutionUuid, onReceive: (response: Response) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'BootcampChatChannel',
        solution_uuid: solutionUuid,
      },
      {
        received: (response: Response) => {
          onReceive(response)
        },
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
