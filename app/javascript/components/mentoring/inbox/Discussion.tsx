import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'
import { Icon } from '../../common/Icon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'

type DiscussionProps = {
  trackTitle: string
  trackIconUrl: string
  studentAvatarUrl: string
  studentHandle: string
  exerciseTitle: string
  isStarred: boolean
  postsCount: number
  updatedAt: string
  url: string
}

export function Discussion({
  trackTitle,
  trackIconUrl,
  studentAvatarUrl,
  studentHandle,
  exerciseTitle,
  isStarred,
  postsCount,
  updatedAt,
  url,
}: DiscussionProps) {
  return (
    <a className="--solution" href={url}>
      <TrackIcon title={trackTitle} iconUrl={trackIconUrl} />
      <Avatar src={studentAvatarUrl} handle={studentHandle} />
      <div className="--info">
        <div className="--handle">
          {studentHandle}
          {isStarred ? <Icon icon="gold-star" alt="Starred student" /> : null}
        </div>
        <div className="--exercise-title">on {exerciseTitle}</div>
      </div>
      <div className="--comments-count">
        <Icon icon="comment" alt={`{postsCount} comments`} />
        {postsCount}
      </div>
      <time className="-updated-at">{fromNow(updatedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
