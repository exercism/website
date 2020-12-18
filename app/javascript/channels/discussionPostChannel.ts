import consumer from '../utils/action-cable-consumer'

export class DiscussionPostChannel {
  subscription: ActionCable.Channel

  constructor(
    {
      discussionId,
      iterationIdx,
    }: { discussionId: number; iterationIdx: number },
    onReceive: () => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'DiscussionPostListChannel',
        discussion_id: discussionId,
        iteration_idx: iterationIdx,
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
