import React from 'react'
import { Avatar, GraphicalIcon, Icon } from './index'
import pluralize from 'pluralize'
import { shortFromNow } from '../../utils/time'
import { MentorDiscussion } from '../types'

export const MentorDiscussionSummary = ({
  links,
  mentor,
  isFinished,
  isUnread,
  postsCount,
  createdAt,
}: MentorDiscussion): JSX.Element => {
  const commentsClass = ['comments', isUnread ? 'unread' : '']

  return (
    <a href={links.self} className="c-mentor-discussion-summary --slim">
      <Avatar src={mentor.avatarUrl} handle={mentor.handle} />
      <div className="info">
        <div className="handle">{mentor.handle}</div>
      </div>
      {isFinished ? null : (
        <div className="c-tag --in-progress --small">In Progress</div>
      )}
      <div className={commentsClass.join(' ')}>
        <Icon
          icon="comment"
          alt={`${postsCount} ${pluralize('comment', postsCount)}`}
        />
        {postsCount}
      </div>
      <time dateTime={createdAt}>{shortFromNow(createdAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
