import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '../../common'
import { MentorDiscussion } from '../../types'

export const AutomationListElement = ({
  representer,
}: {
  representer: MentorDiscussion
}): JSX.Element => {
  return (
    <a className="--representer" href={representer.links.self}>
      <TrackIcon
        title={representer.track.title}
        iconUrl={representer.track.iconUrl}
      />
      <ExerciseIcon
        title={representer.exercise.title}
        iconUrl={representer.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--exercise-title">
          <div>{representer.exercise.title}</div>{' '}
          <div className="--most-popular">Most Popular</div>
        </div>
        <div className="--track-title">in {representer.track.title} (#520)</div>
      </div>
      <div className="--feedback-glimpse">
        Nice use of `input` - I think that’s really great. Let’s exercise this
        more and make this text overflow a bit, so I handle this case
      </div>
      <div className="--occurencies">2534 occurencies</div>
      <time>
        Last shown
        <br />
        {fromNow(representer.updatedAt)}
      </time>
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon textColor6-filter"
      />
    </a>
  )
}
