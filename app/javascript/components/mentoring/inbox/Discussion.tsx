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
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Discussion = ({
  discussion,
}: {
  discussion: MentorDiscussion
}): JSX.Element => {
  const { t } = useAppTranslation('components/mentoring/inbox')

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
                alt={t('discussion.favoriteStudent')}
                className="favorited"
              />
            ) : null}
          </div>
          <div className="--exercise-title">on {discussion.exercise.title}</div>
        </div>
        <div className="--comments-count">
          <Icon
            icon="comment"
            alt={t('discussion.comments', {
              postsCount: discussion.postsCount,
            })}
          />
          {discussion.postsCount}
        </div>
        <time className="-updated-at">{fromNow(discussion.updatedAt)}</time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </a>
    </ExercismTippy>
  )
}
