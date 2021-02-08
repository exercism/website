import React from 'react'
import { Student, StudentMentorRelationship } from '../../Discussion'

export const FinishStep = ({
  relationship,
  student,
  onReset,
}: {
  relationship: StudentMentorRelationship
  student: Student
  onReset: () => void
}): JSX.Element => {
  return (
    <div>
      {relationship.isFavorited ? (
        <p>{student.handle} is one of your favorites.</p>
      ) : (
        <p>Thanks for mentoring.</p>
      )}
      <button type="button" onClick={() => onReset()}>
        Change preferences
      </button>
    </div>
  )
}
