import React, { useCallback } from 'react'
import { Student } from '../../types'
import { Avatar, Reputation, GraphicalIcon, Pronouns } from '../../common'
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
        {/*<div className="bio">{student.bio}</div>*/}
        <Pronouns handle={student.handle} pronouns={student.pronouns} />
        <div className="options">
          {student.links ? (
            <StudentInfoActions student={student} setStudent={setStudent} />
          ) : null}
          <PreviousSessionsLink student={student} setStudent={setStudent} />
        </div>
        {student.trackObjectives ? (
          <details className="track-objectives c-details">
            <summary>
              <div className="--summary-inner">
                Explore {student.handle}'s track goal(s)
                <GraphicalIcon icon="chevron-right" className="--closed-icon" />
                <GraphicalIcon icon="chevron-down" className="--open-icon" />
              </div>
            </summary>
            <p>{student.trackObjectives}</p>
          </details>
        ) : null}
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
  const handleFavorited = useCallback(
    (newStudent) => {
      setStudent({ ...student, isFavorited: newStudent.isFavorited })
    },
    [setStudent, student]
  )

  return (
    <React.Fragment>
      {student.links.favorite ? (
        <FavoriteButton
          student={student as FavoritableStudent}
          onSuccess={handleFavorited}
        />
      ) : null}
    </React.Fragment>
  )
}
