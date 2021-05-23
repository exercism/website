import React, { useState } from 'react'
import { Icon } from '../../common/Icon'
import pluralize from 'pluralize'
import { PreviousMentoringSessionsModal } from '../../modals/PreviousMentoringSessionsModal'
import { Student } from '../../types'

export const PreviousSessionsLink = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element | null => {
  const [open, setOpen] = useState(false)

  if (student.numDiscussionsWithMentor < 2) {
    return null
  }

  const numPrevious = student.numDiscussionsWithMentor - 1

  return (
    <React.Fragment>
      <button
        type="button"
        className="previous-sessions"
        onClick={() => setOpen(true)}
      >
        See {numPrevious} previous {pluralize('session', numPrevious)}
        <Icon icon="modal" alt="Opens in modal" />
      </button>
      {open ? (
        <PreviousMentoringSessionsModal
          open={open}
          student={student}
          setStudent={setStudent}
          onClose={() => setOpen(false)}
        />
      ) : null}
    </React.Fragment>
  )
}
