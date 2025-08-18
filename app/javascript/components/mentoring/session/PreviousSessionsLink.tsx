import React, { useState } from 'react'
import { Icon } from '../../common/Icon'
import pluralize from 'pluralize'
import { PreviousMentoringSessionsModal } from '../../modals/PreviousMentoringSessionsModal'
import { Student } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const PreviousSessionsLink = ({
  student,
  setStudent,
}: {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element | null => {
  const { t } = useAppTranslation('session-batch-3')
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
        {t(
          'components.mentoring.session.previousSessionsLink.seePreviousSessions',
          {
            numPrevious: numPrevious,
            sessions: pluralize('session', numPrevious),
          }
        )}
        <Icon
          icon="modal"
          alt={t(
            'components.mentoring.session.previousSessionsLink.opensInModal'
          )}
        />
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
