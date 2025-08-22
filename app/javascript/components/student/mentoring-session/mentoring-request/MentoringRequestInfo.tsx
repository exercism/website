import React, { useState } from 'react'
import { timeFormat } from '@/utils/time'
import { GraphicalIcon, Icon } from '@/components/common'
import { MedianWaitTime } from '@/components/common/MedianWaitTime'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { IterationMarker } from '@/components/mentoring/session/IterationMarker'
import {
  DiscussionPost,
  DiscussionPostProps,
  DiscussionPostAction,
} from '@/components/mentoring/discussion/DiscussionPost'
import { CancelRequestButton } from './CancelRequestButton'
import type {
  MentorSessionRequest as Request,
  Iteration,
  MentorSessionTrack as Track,
} from '@/components/types'
import type { Video as VideoProps } from '../../MentoringSession'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Links = {
  privateMentoring: string
  mentoringGuide: string
}

const placeholder = {
  contentMarkdown: '',
  contentHtml:
    "<p>Please update this comment to tell a mentor what you'd like to learn in this exercise</p>",
}

export const MentoringRequestInfo = ({
  track,
  links,
  videos,
  request,
  iteration,
}: {
  track: Track
  links: Links
  videos: VideoProps[]
  request: Request
  iteration: Iteration
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/student/mentoring-session/mentoring-request'
  )
  if (!request.comment) {
    throw 'Request comment expected'
  }

  const [action, setAction] = useState<DiscussionPostAction>('viewing')
  const [post, setPost] = useState<DiscussionPostProps>(request.comment)
  const showPlaceholder = post.contentHtml.length === 0

  const postProps = {
    action,
    post: showPlaceholder ? { ...post, ...placeholder } : post,
    onEdit: () => setAction('editing'),
    onEditCancel: () => setAction('viewing'),
    onUpdate: (post: DiscussionPostProps) => setPost(post),
  }

  return (
    <div className="mentoring-requested-section" id="panel-discussion">
      <div className="content">
        <div className="status">
          <div className="info">
            <h3>{t('mentoringRequestInfo.waitingOnMentor')}</h3>
            <MedianWaitTime seconds={track.medianWaitTime} />
          </div>
          <CancelRequestButton request={request} />
        </div>

        <div className="placeholder">
          <div className="info">
            <div className="title">
              <div className="name" />
              <div className="rep" />
            </div>
            <div className="desc" />
          </div>
          <div className="avatar">
            <GraphicalIcon icon="avatar-placeholder" />
          </div>
        </div>

        <div className="c-discussion-timeline">
          <IterationMarker iteration={iteration} userIsStudent={false} />
          <DiscussionPost {...postProps} />
        </div>

        <div className="waiting-box">
          <h3>{t('mentoringRequestInfo.waitingOnMentorQuestion')}</h3>
          <h4>{t('mentoringRequestInfo.howToGetMostOutOfMentoring')}</h4>
          <p>
            {t('mentoringRequestInfo.mentoringRelies')}{' '}
            <Trans
              ns="components/student/mentoring-session/mentoring-request"
              i18nKey="mentoringRequestInfo.readOurGuide"
              components={[
                <a
                  href={links.mentoringGuide}
                  target="_blank"
                  rel="noreferrer"
                />,
                <Icon
                  icon="external-link"
                  alt="The link opens in a new window or tab"
                />,
              ]}
            />
          </p>
          <div className="videos">
            {videos.map((video, i) => (
              <Video key={i} {...video} />
            ))}
          </div>
        </div>
      </div>

      <div className="direct">
        <h3>{t('mentoringRequestInfo.wantAFriend')}</h3>
        <p>{t('mentoringRequestInfo.sendThisLink')}</p>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
    </div>
  )
}

const Video = ({ title, date, thumb, url }: VideoProps) => {
  const { t } = useAppTranslation(
    'components/student/mentoring-session/mentoring-request'
  )
  return (
    <a href={url} target="_blank" rel="noreferrer" className="video">
      <div
        className="img"
        style={{
          backgroundImage: `url('${thumb}')`,
        }}
      />
      <div className="info">
        <div className="title">{title}</div>
        <time dateTime={date} className="date">
          {timeFormat(date, 'DD MMM YYYY')}
        </time>
      </div>
      <Icon
        icon="external-link"
        alt={t('mentoringRequestInfo.newWindowOrTab')}
      />
    </a>
  )
}
