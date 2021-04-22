import React, { useState } from 'react'
import { Icon } from '../../common/Icon'
import pluralize from 'pluralize'
import { PreviousMentoringSessionsModal } from '../../modals/PreviousMentoringSessionsModal'
import { Student } from '../Session'

export const PreviousSessionsLink = ({
  student,
}: {
  student: Student
}): JSX.Element | null => {
  const [open, setOpen] = useState(false)

  if (student.numPreviousSessions === 0) {
    return null
  }

  return (
    <React.Fragment>
      <button
        type="button"
        className="previous-sessions"
        onClick={() => setOpen(true)}
      >
        See {student.numPreviousSessions} previous{' '}
        {pluralize('session', student.numPreviousSessions)}
        <Icon icon="modal" alt="Opens in modal" />
      </button>
      <PreviousMentoringSessionsModal
        open={open}
        student={student}
        onClose={() => setOpen(false)}
      />
    </React.Fragment>
  )
}
