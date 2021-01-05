import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'
import { Icon } from '../../common/Icon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'

type ConversationProps = {
  trackTitle: string
  trackIconUrl: string
  menteeAvatarUrl: string
  menteeHandle: string
  exerciseTitle: string
  isStarred: boolean
  haveMentoredPreviously: boolean
  isNewSubmission: boolean
  postsCount: number
  updatedAt: string
  url: string
}

export function Conversation({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  isNewSubmission,
  postsCount,
  updatedAt,
  url,
}: ConversationProps) {
  return (
    <a className="--solution" href={url}>
      <TrackIcon title={trackTitle} iconUrl={trackIconUrl} />
      <Avatar src={menteeAvatarUrl} handle={menteeHandle} />
      <div className="--info">
        <div className="--handle">
          {menteeHandle}
          {isStarred ? <Icon icon="gold-star" alt="Starred student" /> : null}
        </div>
        <div className="--exercise-title">on {exerciseTitle}</div>
      </div>
      {isNewSubmission ? (
        <div className="--new-iteration">
          <GraphicalIcon icon="stars" />
          New Iteration
        </div>
      ) : null}
      <div className="--comments-count">
        <Icon icon="comment" alt={`{postsCount} comments`} />
        {postsCount}
      </div>
      <time className="-updated-at">{fromNow(updatedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
