import React from 'react'
import { Avatar, Reputation } from '../../common'
import { PreviousSessionsLink } from '../../mentoring/session/PreviousSessionsLink'
import { MentorDiscussionMentor } from '../../types'

export const MentorInfo = ({
  mentor,
}: {
  mentor: MentorDiscussionMentor
}): JSX.Element => {
  return (
    <div className="mentor-info">
      <div className="info">
        <div className="subtitle">Who&apos;s your mentor?</div>
        <div className="name-block">
          <div className="name">{mentor.name}</div>
          <Reputation value={mentor.reputation.toString()} type="primary" />
        </div>
        <div className="handle">{mentor.handle}</div>
        <div className="bio">
          {mentor.bio}
          <span
            className="flags"
            dangerouslySetInnerHTML={{
              __html: '&#127468;&#127463; &#127466;&#127480;',
            }}
          />
        </div>
        <div className="options">
          <PreviousSessionsLink numSessions={mentor.numPreviousSessions} />
        </div>
      </div>
      <Avatar src={mentor.avatarUrl} handle={mentor.handle} />
    </div>
  )
}
