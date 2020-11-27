import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Submission, TestRun } from '../components/student/editor/types'
import { typecheck } from '../utils/typecheck'

export class TestRunChannel {
  subscription: ActionCable.Channel

  constructor(testRun: TestRun, onReceive: (updatedTestRun: TestRun) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'Submission::TestRunsChannel',
        submission_uuid: testRun.submissionUuid,
      },
      {
        received: (response: any) => {
          const formattedResponse = camelizeKeys(response)

          onReceive(typecheck<TestRun>(formattedResponse, 'testRun'))
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
