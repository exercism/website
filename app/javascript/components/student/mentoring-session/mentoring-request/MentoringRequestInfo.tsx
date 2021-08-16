import React, { useState } from 'react'
import { CopyToClipboardButton, GraphicalIcon, Icon } from '../../../common'
import { MentorSessionRequest as Request, Iteration } from '../../../types'
import { timeFormat } from '../../../../utils/time'
import { Video as VideoProps } from '../../MentoringSession'
import { MentorSessionTrack as Track } from '../../../types'
import { IterationMarker } from '../../../mentoring/session/IterationMarker'
import {
  DiscussionPost,
  DiscussionPostProps,
  DiscussionPostAction,
} from '../../../mentoring/discussion/DiscussionPost'

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
            <h3>Waiting on a mentor...</h3>
            <p>Recent median waiting time: ~{track.medianWaitTime}</p>
          </div>
          <a href="#">Cancel Request</a>
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

        <div className="discussion">
          <IterationMarker iteration={iteration} userIsStudent={false} />
          <DiscussionPost {...postProps} />
        </div>

        <div className="waiting-box">
          <h3>Waiting on a mentor?</h3>
          <h4>Learn how to get the most out of mentoring</h4>
          <p>
            Mentoring relies on mentors and students having a shared
            understanding of how it works.{' '}
            <a href={links.mentoringGuide} target="_blank" rel="noreferrer">
              Read our guide
              <Icon
                icon="external-link"
                alt="The link opens in a new window or tab"
              />
            </a>{' '}
            or watch the videos below to get that understanding.
          </p>
          <div className="videos">
            {videos.map((video, i) => (
              <Video key={i} {...video} />
            ))}
          </div>
        </div>
      </div>

      <div className="direct">
        <h3>Want a friend to mentor your solution?</h3>
        <p>Send this link to a friend for private mentoring.</p>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
    </div>
  )
}

const Video = ({ title, date, url }: VideoProps) => {
  return (
    <a href={url} className="video">
      <div className="img" />
      <div className="info">
        <div className="title">{title}</div>
        <time dateTime={date} className="date">
          {timeFormat(date, 'DD MMM YYYY')}
        </time>
      </div>
      <Icon icon="external-link" alt="The link opens in a new window or tab" />
    </a>
  )
}
