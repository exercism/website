import React, { useMemo } from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '../../common'
import { Representation } from '../../types'

export const AutomationListElement = ({
  representation,
  withFeedback,
}: {
  representation: Representation
  withFeedback: boolean
}): JSX.Element => {
  const ELEMENT_LABELS = useMemo(() => {
    return {
      counterElement: withFeedback
        ? `Shown ${representation.numSubmissions} times`
        : `${representation.numSubmissions} occurences`,
      dateElement: withFeedback ? (
        <>
          Last shown
          <br />
          {fromNow(representation.lastSubmittedAt)}
        </>
      ) : (
        <>
          Last occurence
          <br />
          {fromNow(representation.lastSubmittedAt)}
        </>
      ),
    }
  }, [representation, withFeedback])

  return (
    <a className="--representer" href={'string'}>
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
          <div className="--most-popular">Most Popular</div>
        </div>
        <div className="--track-title">
          in {representation.track.title} (#520)
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
        className="action-icon textColor6-filter"
      />
    </a>
  )
}
