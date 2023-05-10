import React, { useMemo } from 'react'
import { pluralizeWithNumber, fromNow } from '@/utils'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '@/components/common'
import { MostPopularTag } from './MostPopularTag'
import type { Representation } from '@/components/types'

export const AutomationListElement = ({
  representation,
  withFeedback,
}: {
  representation: Representation
  withFeedback: boolean
}): JSX.Element => {
  const ELEMENT_LABELS = useMemo(() => {
    const pluralizeNumSubmissions = pluralizeWithNumber.bind(
      null,
      representation.numSubmissions
    )
    return {
      counterElement: withFeedback
        ? `Shown ${pluralizeNumSubmissions('time')}`
        : `${pluralizeNumSubmissions('occurrence')}`,
      dateElement: (
        <>
          Last {withFeedback ? 'shown' : 'occurrence'}
          <br />
          {fromNow(representation.lastSubmittedAt)}
        </>
      ),
    }
  }, [representation, withFeedback])

  return (
    <a className="--representer" href={representation.links.edit}>
      <TrackIcon
        title={representation.track.title}
        iconUrl={representation.track.iconUrl}
      />
      <ExerciseIcon
        title={representation.exercise.title}
        iconUrl={representation.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--exercise-title whitespace-nowrap">
          <div>{representation.exercise.title}</div>{' '}
          {representation.appearsFrequently && <MostPopularTag />}
        </div>
        <div className="--track-title">
          in {representation.track.title} (#{representation.id})
        </div>
      </div>
      <div
        className="--feedback-glimpse"
        dangerouslySetInnerHTML={{ __html: representation.feedbackHtml }}
      ></div>
      <div className="--occurencies">{ELEMENT_LABELS['counterElement']}</div>
      <time className="whitespace-nowrap">{ELEMENT_LABELS['dateElement']}</time>
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon filter-textColor6"
      />
    </a>
  )
}
