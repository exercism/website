import React from 'react'
import { fromNow } from '@/utils/date'
import {
  TrackIcon,
  ExerciseIcon,
  GraphicalIcon,
  Avatar,
  Icon,
} from '@/components/common'
import { ExercismTippy } from '@/components/misc/ExercismTippy'
import { StudentTooltip } from '@/components/tooltips'
import type { MentorDiscussion } from '@/components/types'

export const Discussion = ({
  discussion,
}: {
  discussion: MentorDiscussion
}): JSX.Element => {
  return (
    <ExercismTippy
      content={<StudentTooltip endpoint={discussion.links.tooltipUrl} />}
    >
      <a className="--solution" href={discussion.links.self}>
        <TrackIcon
          title={discussion.track.title}
          iconUrl={discussion.track.iconUrl}
        />
        <ExerciseIcon
          title={discussion.exercise.title}
          iconUrl={discussion.exercise.iconUrl}
        />
        <Avatar
          src={discussion.student.avatarUrl}
          handle={discussion.student.handle}
        />
        <div className="--info">
          <div className="--handle">
            {discussion.student.handle}
            {discussion.student.isFavorited ? (
              <Icon
                icon="gold-star"
                alt="Favorite student"
                className="favorited"
              />
            ) : null}
          </div>
          <div className="--exercise-title">on {discussion.exercise.title}</div>
        </div>
        <div className="--comments-count">
          <Icon icon="comment" alt={`{discussion.postsCount} comments`} />
          {discussion.postsCount}
        </div>
        <time className="-updated-at">{fromNow(discussion.updatedAt)}</time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </a>
    </ExercismTippy>
  )
}
