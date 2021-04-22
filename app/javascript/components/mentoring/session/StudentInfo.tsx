import React from 'react'
import { Student } from '../Session'
import { Avatar, Reputation } from '../../common'
import { FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'

export const StudentInfo = ({ student }: { student: Student }): JSX.Element => {
  return (
    <div className="student-info">
      <div className="info">
        <div className="subtitle">Who you&apos;re mentoring</div>
        <div className="name-block">
          <div className="name">{student.name}</div>
          <Reputation
            value={student.reputation.toString()}
            type="primary"
            size="small"
          />
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
          {student.links ? <StudentInfoActions student={student} /> : null}
          <PreviousSessionsLink numSessions={student.numPreviousSessions} />
        </div>
      </div>
      <Avatar src={student.avatarUrl} handle={student.handle} />
    </div>
  )
}

const StudentInfoActions = ({ student }: { student: Student }) => {
  return (
    <div className="options">
      {student.isFavorite !== undefined && student.links?.favorite ? (
        <FavoriteButton
          isFavorite={student.isFavorite}
          endpoint={student.links.favorite}
        />
      ) : null}
    </div>
  )
}
