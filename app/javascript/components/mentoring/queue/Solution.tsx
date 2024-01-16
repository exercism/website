import React from 'react'
import { fromNow } from '../../../utils/time'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { Avatar } from '../../common/Avatar'
import { StudentTooltip } from '../../tooltips'
import { MentoringRequest } from './useMentoringQueue'
import { ExercismTippy } from '../../misc/ExercismTippy'

export const Solution = ({
  student,
  exercise,
  isFavorited,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  tooltipUrl,
}: MentoringRequest): JSX.Element => {
  return (
    <ExercismTippy content={<StudentTooltip endpoint={tooltipUrl} />}>
      <a href={url} className="--solution">
        <ExerciseIcon title={exercise.title} iconUrl={exercise.iconUrl} />
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="--info">
          <div className="--handle">
            {student.handle}
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
          <div className="--exercise-title">on {exercise.title}</div>
        </div>
        {status ? <div className="--status">{status}</div> : null}
        <time className="-updated-at">{fromNow(updatedAt)}</time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </a>
    </ExercismTippy>
  )
}
