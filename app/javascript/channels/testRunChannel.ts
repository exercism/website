import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Submission } from '../components/student/Editor'
import { TestRun } from '../components/student/editor/TestRunSummary'

export class TestRunChannel {
  subscription: ActionCable.Channel

  constructor(submission: Submission, received: (testRun: TestRun) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'Submission::TestRunsChannel',
        submission_uuid: submission.uuid,
      },
      {
        received: (response: { test_run: any }) => {
          const formattedResponse = camelizeKeys(response) as {
            testRun: TestRun
          }

          received(formattedResponse.testRun)
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
