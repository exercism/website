import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/track/IterationSummary'
import { typecheck } from '../utils/typecheck'

export class IterationChannel {
  subscription: ActionCable.Channel

  constructor(iteration: Iteration, onReceive: (iteration: Iteration) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'IterationChannel',
        id: iteration.id,
      },
      {
        received: (response: any) => {
          const formattedResponse = camelizeKeys(response)

          onReceive(typecheck<Iteration>(formattedResponse, 'iteration'))
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
