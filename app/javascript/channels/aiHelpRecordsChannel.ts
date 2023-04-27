import { AIHelpRecordsChannelResponse } from '@/components/editor/ChatGptFeedback/useChatGptFeedback'
import consumer from '../utils/action-cable-consumer'

export class AIHelpRecordsChannel {
  subscription: ActionCable.Channel

  constructor(
    submission_uuid: string,
    onReceive: (response: AIHelpRecordsChannelResponse) => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'Submission::AIHelpRecordsChannel',
        submission_uuid: submission_uuid,
      },
      {
        received: (response: AIHelpRecordsChannelResponse) => {
          onReceive(response)
        },
      }
    )
  }

  disconnect(): void {
    this.subscription.unsubscribe()
  }
}
