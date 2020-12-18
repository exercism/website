import consumer from '../utils/action-cable-consumer'

export class DiscussionPostChannel {
  subscription: ActionCable.Channel

  constructor(
    {
      discussionId,
      iterationId,
    }: { discussionId: number; iterationId: number },
    onReceive: () => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'DiscussionPostListChannel',
        discussion_id: discussionId,
        iteration_id: iterationId,
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
