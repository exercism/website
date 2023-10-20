import React, { useContext, useState } from 'react'
import { Avatar, Reputation } from '@/components/common'
import type { Student } from '@/components/types'
import { PreviousSessionsLink } from './PreviousSessionsLink'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'
import { Pronouns } from '@/components/common/Pronouns'
import { ScreenSizeContext } from './ScreenSizeContext'
import { ToggleMoreInformationButton } from './student-info/ToggleMoreInformationButton'
import { StudentInfoActions } from './student-info/StudentInfoActions'
import { StudentTrackObjectives } from './student-info/StudentTrackObjectives'
import { ReducedStudentInfo } from './student-info/ReducedStudentInfo'

export const StudentInfo = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element => {
  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}
  const [showMoreInformation, setShowMoreInformation] = useState(false)

  if (!showMoreInformation && isBelowLgWidth)
    return (
      <ReducedStudentInfo
        student={student}
        onClick={() => setShowMoreInformation(true)}
      />
    )
  else
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
          {!isBelowLgWidth && (
            <PreviousSessionsLink student={student} setStudent={setStudent} />
          )}
        </div>
        <StudentTrackObjectives student={student} />

        {isBelowLgWidth && (
          <ToggleMoreInformationButton
            rotate
            onClick={() => setShowMoreInformation(false)}
          />
        )}
      </div>
    )
}
