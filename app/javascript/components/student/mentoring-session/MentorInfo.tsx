import React from 'react'
import { Avatar, Reputation, Pronouns } from '../../common'
import { Mentor } from '../MentoringSession'

export const MentorInfo = ({ mentor }: { mentor: Mentor }): JSX.Element => {
  return (
    <div className="mentor-info">
      <div className="info">
        <div className="subtitle">Meet your mentor</div>
        <div className="handle-block">
          <div className="handle">{mentor.handle}</div>
          <Reputation
            value={mentor.formattedReputation.toString()}
            type="primary"
            size="small"
          />
        </div>
        <div className="name">{mentor.name}</div>
        <Pronouns handle={mentor.handle} pronouns={mentor.pronouns} />
        {/*<div className="bio">{mentor.bio}</div>*/}
        {/* TODO: (required) View previous sessions as a student */}
      </div>
      <Avatar src={mentor.avatarUrl} handle={mentor.handle} />
    </div>
  )
}
