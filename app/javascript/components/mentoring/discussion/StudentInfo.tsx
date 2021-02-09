import React from 'react'
import { Student } from '../Discussion'
import { Avatar, Reputation } from '../../common'
import { FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'

export const StudentInfo = ({ student }: { student: Student }): JSX.Element => {
  return (
    <div className="student-info">
      <div className="info">
        <div className="subtitle">Who you're mentoring</div>
        <div className="name-block">
          <div className="name">{student.name}</div>
          <Reputation value={student.reputation.toString()} type="primary" />
        </div>
        <div className="handle">{student.handle}</div>
        <div className="bio">
          {student.bio}
          <span
            className="flags"
            dangerouslySetInnerHTML={{
              __html: '&#127468;&#127463; &#127466;&#127480;',
            }}
          />
          {/*TODO: Map these to codes like above {student.languagesSpoken.join(', ')}*/}
        </div>
        <div className="options">
          <FavoriteButton
            isFavorite={student.isFavorite}
            endpoint={student.links.favorite}
          />
          <PreviousSessionsLink numSessions={student.numPreviousSessions} />
        </div>
      </div>
      <Avatar src={student.avatarUrl} handle={student.handle} />
    </div>
  )
}
