import consumer from '../utils/action-cable-consumer'
import { unsubscribeFromWebsocketsSoon } from '../utils/unsubscribe-soon'
import { camelizeKeys } from 'humps'
import { Metric } from '@/components/types'
function camelizeKeysAs<T>(object: any): T {
  return camelizeKeys(object) as unknown as T
}
export type MetricsChannelResponse = {
  metric: Metric
}

export class MetricsChannel {
  subscription: ActionCable.Channel

  constructor(onReceive: (metric: Metric) => void) {
    this.subscription = consumer.subscriptions.create(
      {
        channel: 'MetricsChannel',
      },
      {
        received: (data) => {
          if (!onReceive) {
            return
          }

          onReceive(camelizeKeysAs<Metric>(data.metric))
        },
      }
    )
  }

  disconnect(): void {
    unsubscribeFromWebsocketsSoon(this.subscription)
  }
}
