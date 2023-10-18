import React from 'react'
import type { Student } from '@/components/types'
import { Avatar, GraphicalIcon, Reputation } from '@/components/common'
import { FavoritableStudent, FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'
import { Pronouns } from '@/components/common/Pronouns'

export const StudentInfo = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element => {
  return (
    <div className="student-info">
      <div className="flex mb-8">
        <div className="flex-grow">
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
          <Pronouns handle={student.handle} pronouns={student.pronouns} />
        </div>
        <Avatar src={student.avatarUrl} handle={student.handle} />
      </div>
      <div className="bio">{student.bio}</div>
      <div className="options">
        {student.links ? (
          <StudentInfoActions student={student} setStudent={setStudent} />
        ) : null}
        <PreviousSessionsLink student={student} setStudent={setStudent} />
      </div>
      <StudentTrackObjectives student={student} />
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

function StudentTrackObjectives({
  student,
}: {
  student: Student
}): JSX.Element | null {
  if (!student.trackObjectives) return null

  return (
    <details className="track-objectives c-details">
      <summary>
        <div className="--summary-inner justify-between select-none">
          Explore {student.handle}&apos;s track goal(s)
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </div>
      </summary>
      <p>{student.trackObjectives}</p>
    </details>
  )
}
