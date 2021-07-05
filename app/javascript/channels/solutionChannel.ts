import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/types'

export type ChannelResponse = {
  solution: Solution
  iterations: readonly Iteration[]
}

/* TODO: We have yet to have an official Solution type */
type Solution = any

export class SolutionChannel {
  subscription: ActionCable.Channel

  constructor(
    solution: Solution,
    onReceive: (response: ChannelResponse) => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'SolutionChannel',
        uuid: solution.uuid,
      },
      {
        received: (response: {
          solution: Solution
          iterations: readonly Iteration[]
        }) => {
          onReceive(camelizeKeys(response) as ChannelResponse)
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
