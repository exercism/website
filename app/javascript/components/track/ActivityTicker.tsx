import React from 'react'
import { fromNow } from '@/utils/time'
import { assembleClassNames } from '@/utils/assemble-classnames'
import * as Elements from './activity-ticker'

export default function ActivityTicker({
  trackTitle,
  initialData,
}: Elements.ActivityTickerProps) {
  const { metric, animation } = Elements.useActivityTicker({
    trackTitle,
    initialData,
  })

  if (!metric) return
  return (
    <div className={assembleClassNames('flex items-start', animation)}>
      {metric.user ? (
        <Elements.UserAvatar user={metric.user} />
      ) : (
        <Elements.Flag countryCode={metric.countryCode} />
      )}
      <div className="flex flex-col">
        <div className="text-16 leading-160 mb-4 ">
          <Elements.Handle
            user={metric.user}
            countryName={metric.countryName}
          />
          &nbsp;
          {Elements.METRIC_TEXT[metric.type]}
          {metric.exercise && (
            <Elements.ExerciseWidget exercise={metric.exercise} />
          )}
        </div>
        <div className="text-14 text-textColor7">
          {fromNow(metric.occurredAt)}
        </div>
      </div>
    </div>
  )
}
