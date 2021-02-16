import React from 'react'
import { Partner, StudentMentorRelationship } from '../../Session'
import { GraphicalIcon } from '../../../common/GraphicalIcon'

export const FinishStep = ({
  relationship,
  student,
  onReset,
}: {
  relationship: StudentMentorRelationship
  student: Partner
  onReset: () => void
}): JSX.Element => {
  return (
    <div>
      {relationship.isFavorited ? (
        <p>{student.handle} is one of your favorites.</p>
      ) : relationship.isBlocked ? (
        <p>You will not see future mentor requests from {student.handle}.</p>
      ) : (
        <p>Thanks for mentoring {student.handle}.</p>
      )}
      <button className="btn-link" type="button" onClick={() => onReset()}>
        <GraphicalIcon icon="reset" />
        Change preferences
      </button>
    </div>
  )
}
