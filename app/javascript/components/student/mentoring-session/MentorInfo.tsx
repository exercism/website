import React from 'react'
import { Avatar, HandleWithFlair, Reputation } from '@/components/common'
import { Mentor } from '../MentoringSession'

export const MentorInfo = ({ mentor }: { mentor: Mentor }): JSX.Element => {
  return (
    <div className="mentor-info">
      <div className="info">
        <div className="subtitle">Meet your mentor</div>
        <div className="handle-block">
          <div className="handle">
            {
              <HandleWithFlair
                handle={mentor.handle}
                flair={mentor.flair}
                size="medium"
              />
            }
          </div>
          <Reputation
            value={mentor.reputation.toString()}
            type="primary"
            size="small"
          />
        </div>
        <div className="name">{mentor.name}</div>
        <div className="bio">{mentor.bio}</div>
        {/* TODO: (required) View previous sessions as a student */}
      </div>
      <Avatar src={mentor.avatarUrl} handle={mentor.handle} />
    </div>
  )
}
