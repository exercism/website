import React from 'react'
import { fromNow } from '../../../utils/time'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { Avatar } from '../../common/Avatar'
import { StudentTooltip } from '../../tooltips'
import { LazyTippy } from '../../misc/LazyTippy'
import { followCursor } from 'tippy.js'
import { MentoringRequest } from './useMentoringQueue'

export const Solution = ({
  studentAvatarUrl,
  studentHandle,
  exerciseTitle,
  exerciseIconUrl,
  isFavorited,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  tooltipUrl,
}: MentoringRequest): JSX.Element => {
  return (
    <LazyTippy
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
      content={<StudentTooltip endpoint={tooltipUrl} requestId={tooltipUrl} />}
    >
      <a href={url} className="--solution">
        <ExerciseIcon title={exerciseTitle} iconUrl={exerciseIconUrl} />
        <Avatar src={studentAvatarUrl} handle={studentHandle} />
        <div className="--info">
          <div className="--handle">
            {studentHandle}
            {isFavorited ? (
              <Icon
                icon="gold-star"
                alt="Favorite student"
                className="favorited"
              />
            ) : haveMentoredPreviously ? (
              <Icon
                icon="mentoring"
                alt="Mentored previously"
                className="previously-mentored"
              />
            ) : null}
          </div>
          <div className="--exercise-title">on {exerciseTitle}</div>
        </div>
        {status ? <div className="--status">{status}</div> : null}
        <time className="-updated-at">{fromNow(updatedAt)}</time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </a>
    </LazyTippy>
  )
}
