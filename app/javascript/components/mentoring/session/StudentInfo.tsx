import React from 'react'
import { Student } from '../Session'
import { Avatar, Reputation } from '../../common'
import { FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'

export const StudentInfo = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element => {
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
          {student.links ? (
            <StudentInfoActions student={student} setStudent={setStudent} />
          ) : null}
          <PreviousSessionsLink student={student} setStudent={setStudent} />
        </div>
      </div>
      <Avatar src={student.avatarUrl} handle={student.handle} />
    </div>
  )
}

const StudentInfoActions = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}) => {
  return (
    <div className="options">
      <FavoriteButton
        student={student}
        onSuccess={(student) => setStudent(student)}
      />
    </div>
  )
}
