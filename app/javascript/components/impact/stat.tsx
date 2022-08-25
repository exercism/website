import React, { useEffect, useState } from 'react'
import {
  MetricsChannel,
  MetricsChannelResponse,
} from '../../channels/metricsChannel'

export default ({
  metric,
  initialValue,
}: {
  metric: string
  initialValue: number
}): JSX.Element => {
  const [value, setValue] = useState(initialValue)

  useEffect(() => {
    const connection = new MetricsChannel((data: MetricsChannelResponse) => {
      if (metric != data.metric.type) {
        return
      }

      setValue(value + 1)
    })

    return () => connection.disconnect()
  }, [value])

  return <>{value.toLocaleString()}</>
}
