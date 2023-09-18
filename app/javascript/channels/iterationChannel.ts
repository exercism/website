import consumer from '../utils/action-cable-consumer'

import { camelizeKeys } from 'humps'
import { Iteration } from '../components/types'
import { typecheck } from '../utils/typecheck'

export class IterationChannel {
  subscription: ActionCable.Channel

  constructor(uuid: string, onReceive: (iteration: Iteration) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'IterationChannel',
        uuid: uuid,
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
