import React from 'react'
import { Student } from '../../types'
import { Avatar, Reputation } from '../../common'
import { FavoritableStudent, FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'

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
        <div className="handle-block">
          <div className="handle">
            <HandleWithFlair
              handle={student.handle}
              flair={student.flair}
              size="medium"
            />
          </div>
          <Reputation
            value={student.reputation.toString()}
            type="primary"
            size="small"
          />
        </div>
        <div className="name">{student.name}</div>
        <div className="bio">{student.bio}</div>
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
    <React.Fragment>
      {student.links.favorite ? (
        <FavoriteButton
          student={student as FavoritableStudent}
          onSuccess={(student) => setStudent(student)}
        />
      ) : null}
    </React.Fragment>
  )
}
