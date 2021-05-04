import React from 'react'
import { Student } from '../../Session'
import { GraphicalIcon } from '../../../common/GraphicalIcon'

export const FinishStep = ({
  student,
  onReset,
}: {
  student: Student
  onReset: () => void
}): JSX.Element => {
  return (
    <div>
      {student.isFavorited ? (
        <p>{student.handle} is one of your favorites.</p>
      ) : student.isBlocked ? (
        <p>You will not see future mentor requests from {student.handle}.</p>
      ) : (
        <p>Thanks for mentoring {student.handle}.</p>
      )}
      <button className="btn-link" type="button" onClick={() => onReset()}>
        <GraphicalIcon icon="reset" />
        <span>Change preferences</span>
      </button>
    </div>
  )
}
