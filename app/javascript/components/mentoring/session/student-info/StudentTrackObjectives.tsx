// i18n-key-prefix: studentTrackObjectives
// i18n-namespace: components/mentoring/session/student-info
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import type { Student } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function StudentTrackObjectives({
  student,
}: {
  student: Student
}): JSX.Element | null {
  const { t } = useAppTranslation('components/mentoring/session/student-info')
  if (!student.trackObjectives) return null

  return (
    <details className="track-objectives c-details">
      <summary>
        <div className="--summary-inner justify-between select-none">
          {t('studentTrackObjectives.exploreTrackGoals', {
            handle: student.handle,
          })}
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </div>
      </summary>
      <p>{student.trackObjectives}</p>
    </details>
  )
}
