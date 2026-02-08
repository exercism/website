import { MetricsChannel } from '@/channels/metricsChannel'
import { Metric } from '@/components/types'
import { useState, useEffect } from 'react'
import { METRIC_TYPES, allowedMetricTypes } from './ActivityTicker.types'

export function useActivityTicker({ initialData, trackTitle }): {
  metric: Metric
  metricKey: number
  animation: 'animate-fadeIn' | 'animate-fadeOut'
} {
  const [metric, setMetric] = useState<Metric>(initialData)
  const [isVisible, setIsVisible] = useState(true)
  const [metricKey, setMetricKey] = useState(0)

  useEffect(() => {
    const connection = new MetricsChannel((metric) => {
      if (
        METRIC_TYPES.indexOf(metric.type as allowedMetricTypes) === -1 ||
        (trackTitle && trackTitle !== metric.track?.title)
      )
        return

      setIsVisible(false)
      setTimeout(() => {
        setMetricKey((prev) => prev + 1)
        setMetric(metric)
        setIsVisible(true)
      }, 300)
    })
    return () => connection.disconnect()
  }, [])

  return {
    metric,
    metricKey,
    animation: isVisible ? 'animate-fadeIn' : 'animate-fadeOut',
  }
}
