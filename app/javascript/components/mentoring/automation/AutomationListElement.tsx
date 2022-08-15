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
      <div className="--occurencies">2534 occurencies</div>
      <time>{fromNow(representer.updatedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
