import React from 'react'
import { fromNow } from '../../../utils/time'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { Avatar } from '../../common/Avatar'

type SolutionProps = {
  studentAvatarUrl: string
  studentHandle: string
  exerciseTitle: string
  exerciseIconUrl: string
  isStarred: boolean
  haveMentoredPreviously: boolean
  status: string
  updatedAt: string
  url: string
  showMoreInformation: (e: React.MouseEvent | React.FocusEvent) => void
  hideMoreInformation: () => void
}

export function Solution({
  studentAvatarUrl,
  studentHandle,
  exerciseTitle,
  exerciseIconUrl,
  isStarred,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  showMoreInformation,
  hideMoreInformation,
}: SolutionProps) {
  return (
    <a
      href={url}
      className="--solution"
      onMouseEnter={showMoreInformation}
      onMouseLeave={hideMoreInformation}
      onFocus={showMoreInformation}
      onBlur={hideMoreInformation}
    >
      <ExerciseIcon title={exerciseTitle} iconUrl={exerciseIconUrl} />
      <Avatar src={studentAvatarUrl} handle={studentHandle} />
      <div className="--info">
        <div className="--handle">
          {studentHandle}
          {isStarred ? <Icon icon="gold-star" alt="Starred student" /> : null}
          {haveMentoredPreviously ? <div className="dot" /> : null}
        </div>
        <div className="--exercise-title">on {exerciseTitle}</div>
      </div>
      <div className="--status">{status}</div>
      <time className="-updated-at">{fromNow(updatedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
