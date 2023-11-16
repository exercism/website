import React, { useEffect, useState } from 'react'
import { MetricsChannel } from '@/channels/metricsChannel'
import { Metric, MetricUser } from '../types'
import { fromNow } from '@/utils/time'

export type ActivityTickerProps = { trackTitle: string; initialData: Metric }

const METRIC_TYPES = [
  'publish_solution_metric',
  'open_pull_request_metric',
  'merge_pull_request_metric',
] as const

const METRIC_TEXT = {
  publish_solution_metric: `published a new solution`,
  open_pull_request_metric: `submitted a Pull Request on Exercism's GitHub`,
  merge_pull_request_metric: `had a Pull Request merged on Exercism's GitHub`,
}

type allowedMetricTypes = typeof METRIC_TYPES[number]

export default function ActivityTicker({
  trackTitle,
  initialData,
}: ActivityTickerProps) {
  const [metric, setMetric] = useState<Metric>(initialData)
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    const connection = new MetricsChannel((metric) => {
      if (
        METRIC_TYPES.indexOf(metric.type as allowedMetricTypes) === -1 ||
        (trackTitle && trackTitle !== metric.track?.title)
      )
        return

      console.log(metric)
      setIsVisible(false)
      setTimeout(() => {
        setMetric(metric)
        setIsVisible(true)
      }, 300)
    })
    return () => connection.disconnect()
  }, [])

  if (!metric) return
  return (
    <div
      className={`flex items-start ${
        isVisible ? 'animate-fadeIn' : 'animate-fadeOut'
      }`}
    >
      <UserAvatar user={metric.user} />
      <div className="flex flex-col">
        <div className="text-16 leading-140 mb-4">
          <Handle user={metric.user} />
          &nbsp;
          {METRIC_TEXT[metric.type]}
        </div>
        <div className="text-14 text-textColor7">
          {fromNow(metric.occurredAt)}
        </div>
      </div>
    </div>
  )
}

function UserAvatar({ user }: { user?: MetricUser }): JSX.Element | null {
  if (!user) return null
  return (
    <img
      src={user.avatarUrl}
      alt={`${user.handle}'s avatar`}
      className="w-[36px] h-[36px] rounded-circle mr-12 mt-4"
    />
  )
}

function Handle({ user }: { user?: MetricUser }) {
  if (!user) return 'A user'

  const { handle, links } = user

  return links?.self ? (
    <a href={links.self} className="text-linkColor font-semibold">
      {handle}
    </a>
  ) : (
    <span className="font-semibold">{handle}</span>
  )
}
