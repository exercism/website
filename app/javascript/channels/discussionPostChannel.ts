import consumer from '../utils/action-cable-consumer'

export class DiscussionPostChannel {
  subscription: ActionCable.Channel

  constructor(
    { discussionUuid }: { discussionUuid: string },
    onReceive: () => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'DiscussionPostListChannel',
        discussion_uuid: discussionUuid,
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
