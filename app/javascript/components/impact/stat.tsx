import React, { useEffect, useState } from 'react'
import { MetricsChannel } from '../../channels/metricsChannel'
import { Metric } from '../types'
export default ({
  metricType,
  initialValue,
}: {
  metricType: string
  initialValue: number
}): JSX.Element => {
  const [value, setValue] = useState(initialValue)

  useEffect(() => {
    const connection = new MetricsChannel((metric: Metric) => {
      if (metricType != metric.type) {
        return
      }

      setValue(value + 1)
    })

    return () => connection.disconnect()
  }, [value])

  return <>{value.toLocaleString()}</>
}
