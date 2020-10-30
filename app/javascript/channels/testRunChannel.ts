import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { TestRun } from '../components/student/Editor'
import { typecheck } from '../utils/typecheck'

export class TestRunChannel {
  subscription: ActionCable.Channel

  constructor(testRun: TestRun, onReceive: (testRun: TestRun) => void) {
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
