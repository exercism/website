import consumer from '../utils/action-cable-consumer'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/types'

export type ChannelResponse = {
  solution: Solution
  iteration: Iteration
}

/* TODO: We have yet to have an official Solution type */
type Solution = any

export class LatestIterationChannel {
  subscription: ActionCable.Channel

  constructor(
    solution: Solution,
    onReceive: (response: ChannelResponse) => void
  ) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'LatestIterationChannel',
        uuid: solution.uuid,
      },
      {
        received: (response: { solution: Solution; iteration: Iteration }) => {
          onReceive(camelizeKeys(response) as ChannelResponse)
        },
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}
