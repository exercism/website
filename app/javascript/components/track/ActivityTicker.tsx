import React from 'react'
import { Trans } from 'react-i18next'
import { fromNow } from '@/utils/time'
import { assembleClassNames } from '@/utils/assemble-classnames'
import * as Elements from './activity-ticker'

const NAMESPACE = 'components/track/activity-ticker'

export default function ActivityTicker({
  trackTitle,
  initialData,
}: Elements.ActivityTickerProps) {
  const { metric, metricKey, animation } = Elements.useActivityTicker({
    trackTitle,
    initialData,
  })

  if (!metric) return

  const handle = (
    <Elements.Handle user={metric.user} countryName={metric.countryName} />
  )

  // Sentence slots. Which ones a sentence uses depends on the metric type:
  // solution-publishing links to the solution AND names the exercise, pull
  // request metrics link to the PR, the rest just name the exercise.
  const solutionLink = metric.publishedSolutionUrl ? (
    <Elements.PublishedSolutionLink
      publishedSolutionUrl={metric.publishedSolutionUrl}
    />
  ) : (
    <></>
  )
  const pullRequest = metric.pullRequest ? (
    <Elements.PullRequestLink pullRequest={metric.pullRequest} />
  ) : (
    <></>
  )
  const exercise = metric.exercise ? (
    <Elements.ExerciseWidget exercise={metric.exercise} />
  ) : (
    <></>
  )

  return (
    <div
      key={metricKey}
      className={assembleClassNames('flex items-start', animation)}
    >
      {metric.user || !metric.countryCode ? (
        <Elements.UserAvatar user={metric.user} />
      ) : (
        <Elements.Flag countryCode={metric.countryCode} />
      )}
      <div className="flex flex-col">
        <div className="text-16 leading-160 mb-4 ">
          {/* One whole sentence per metric type, so translators control word order. */}
          <Trans
            ns={NAMESPACE}
            i18nKey={`sentence.${metric.type}`}
            components={[handle, solutionLink, pullRequest, exercise]}
          />
        </div>
        <div className="text-14 text-textColor7">
          {fromNow(metric.occurredAt)}
        </div>
      </div>
    </div>
  )
}
