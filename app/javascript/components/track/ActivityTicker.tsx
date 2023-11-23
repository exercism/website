import React from 'react'
import { fromNow } from '@/utils/time'
import * as Component from './activity-ticker'

export default function ActivityTicker({
  trackTitle,
  initialData,
}: Component.ActivityTickerProps) {
  const { metric, isVisible } = Component.useActivityTicker({
    trackTitle,
    initialData,
  })

  if (!metric) return
  return (
    <div
      className={`flex items-start ${
        isVisible ? 'animate-fadeIn' : 'animate-fadeOut'
      }`}
    >
      <Component.UserAvatar user={metric.user} />
      <div className="flex flex-col">
        <div className="text-16 leading-160 mb-4 ">
          <Component.Handle user={metric.user} />
          &nbsp;
          {Component.METRIC_TEXT[metric.type]}
          {metric.exercise && (
            <Component.ExerciseWidget exercise={metric.exercise} />
          )}
        </div>
        <div className="text-14 text-textColor7">
          {fromNow(metric.occurredAt)}
        </div>
      </div>
    </div>
  )
}
