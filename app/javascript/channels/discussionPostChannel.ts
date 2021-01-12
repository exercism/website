import consumer from '../utils/action-cable-consumer'

export class DiscussionPostChannel {
  subscription: ActionCable.Channel

  constructor(
    { discussionId }: { discussionId: number },
    onReceive: () => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'DiscussionPostListChannel',
        discussion_id: discussionId,
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
