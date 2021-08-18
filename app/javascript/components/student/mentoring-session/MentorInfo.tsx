import React from 'react'
import { Avatar, Reputation } from '../../common'
import { Mentor } from '../MentoringSession'

export const MentorInfo = ({ mentor }: { mentor: Mentor }): JSX.Element => {
  return (
    <div className="mentor-info">
      <div className="info">
        <div className="subtitle">Meet your mentor</div>
        <div className="name-block">
          <div className="name">{mentor.name}</div>
          <Reputation value={mentor.reputation.toString()} type="primary" />
        </div>
        <div className="handle">{mentor.handle}</div>
        <div className="bio">{mentor.bio}</div>
        {/* TODO: (required) View previous sessions as a student */}
      </div>
      <Avatar src={mentor.avatarUrl} handle={mentor.handle} />
    </div>
  )
}
