import React from 'react'
import { CopyToClipboardButton, GraphicalIcon, Icon } from '../../common'
import { RequestDetails } from '../../mentoring/request/RequestDetails'
import { MentoringRequest, Iteration } from '../../types'
import { timeFormat } from '../../../utils/time'
import { Track, Video as VideoProps } from '../MentoringRequest'

type Links = {
  privateMentoring: string
  mentoringGuide: string
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
  request: MentoringRequest
  iteration: Iteration
}): JSX.Element => {
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

        <RequestDetails request={request} iteration={iteration} />

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
        <div className="date">{timeFormat(date, 'DD MMM YYYY')}</div>
      </div>
      <Icon icon="external-link" alt="The link opens in a new window or tab" />
    </a>
  )
}
