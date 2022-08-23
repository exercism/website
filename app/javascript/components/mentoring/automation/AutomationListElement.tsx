import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '../../common'
import { MentorDiscussion } from '../../types'

export const AutomationListElement = ({
  representation,
}: {
  representation: MentorDiscussion
}): JSX.Element => {
  return (
    <a className="--representation" href={'string'}>
      <TrackIcon
        title={representation.track.title}
        iconUrl={representation.track.iconUrl}
      />
      <ExerciseIcon
        title={representation.exercise.title}
        iconUrl={representation.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--exercise-title">
          <div>{representation.exercise.title}</div>{' '}
          <div className="--most-popular">Most Popular</div>
        </div>
        <div className="--track-title">
          in {representation.track.title} (#520)
        </div>
      </div>
      <div className="--feedback-glimpse">
        Nice use of `input` - I think that’s really great. Let’s exercise this
        more and make this text overflow a bit, so I handle this case
      </div>
      <div className="--occurencies">2534 occurencies</div>
      <time>
        Last shown
        <br />
        {fromNow(representation.lastSubmittedAt)}
      </time>
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon textColor6-filter"
      />
    </a>
  )
}
