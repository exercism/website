import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'
import { Icon } from '../../common/Icon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'
import { MentorDiscussion } from '../../types'

export function Discussion({
  track,
  student,
  exercise,
  isStarred,
  postsCount,
  createdAt,
  links,
}: MentorDiscussion): JSX.Element {
  return (
    <a className="--solution" href={links.self}>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <Avatar src={student.avatarUrl} handle={student.handle} />
      <div className="--info">
        <div className="--handle">
          {student.handle}
          {isStarred ? <Icon icon="gold-star" alt="Starred student" /> : null}
        </div>
        <div className="--exercise-title">on {exercise.title}</div>
      </div>
      <div className="--comments-count">
        <Icon icon="comment" alt={`{postsCount} comments`} />
        {postsCount}
      </div>
      <time className="-updated-at">{fromNow(createdAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
