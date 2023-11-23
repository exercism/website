import React, { useEffect, useState } from 'react'
import { MetricsChannel } from '@/channels/metricsChannel'
import { Metric, MetricUser } from '../types'
import { fromNow } from '@/utils/time'
import { useLogger } from '@/hooks'

export type ActivityTickerProps = { trackTitle: string; initialData: Metric }

const METRIC_TYPES = [
  'publish_solution_metric',
  'open_pull_request_metric',
  'merge_pull_request_metric',
  'start_solution_metric',
  'submit_submission_metric',
  'complete_solution_metric',
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

      setIsVisible(false)
      setTimeout(() => {
        setMetric(metric)
        setIsVisible(true)
      }, 300)
    })
    return () => connection.disconnect()
  }, [])

  useLogger('metric', metric)

  if (!metric) return
  return (
    <div
      className={`flex items-start ${
        isVisible ? 'animate-fadeIn' : 'animate-fadeOut'
      }`}
    >
      <UserAvatar user={metric.user} />
      <div className="flex flex-col">
        <div className="text-16 leading-160 mb-4 ">
          <Handle user={metric.user} />
          &nbsp;
          {METRIC_TEXT[metric.type]}
          {metric.exercise && <ExerciseWidget exercise={metric.exercise} />}
        </div>
        <div className="text-14 text-textColor7">
          {fromNow(metric.occurredAt)}
        </div>
      </div>
    </div>
  )
}

function ExerciseWidget({
  exercise,
}: {
  exercise: Record<'exerciseUrl' | 'iconUrl' | 'title', string>
}) {
  return (
    <span className="inline-flex">
      &nbsp;to&nbsp;
      <a
        href={exercise.exerciseUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        <img src={exercise.iconUrl} className="w-[24px] h-[24px] mr-8" />
        {exercise.title}
      </a>
    </span>
  )
}

function UserAvatar({ user }: { user?: MetricUser }): JSX.Element | null {
  if (!user) return null
  return (
    <img
      src={user.avatarUrl}
      alt={`${user.handle}'s avatar`}
      className="w-[36px] h-[36px] rounded-circle mr-12"
    />
  )
}

function Handle({ user }: { user?: MetricUser }) {
  if (!user) return 'A user'

  const { handle, links } = user

  return links?.self ? (
    <a href={links.self} className="text-prominentLinkColor font-semibold">
      {handle}
    </a>
  ) : (
    <span className="font-semibold">{handle}</span>
  )
}
