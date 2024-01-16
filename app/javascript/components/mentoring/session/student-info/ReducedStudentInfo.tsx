import React from 'react'
import { HandleWithFlair, Reputation, Avatar } from '@/components/common'
import { Student } from '@/components/types'
import { ToggleMoreInformationButton } from './ToggleMoreInformationButton'

export function ReducedStudentInfo({
  student,
  onClick,
}: {
  student: Student
  onClick: () => void
}): JSX.Element {
  return (
    <div className="student-info">
      <div className="flex">
        <div className="flex-grow">
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
        </div>
        <Avatar src={student.avatarUrl} handle={student.handle} />
      </div>

      <ToggleMoreInformationButton onClick={onClick} />
    </div>
  )
}
