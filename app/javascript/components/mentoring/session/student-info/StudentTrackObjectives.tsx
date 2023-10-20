import React from 'react'
import { GraphicalIcon } from '@/components/common'
import type { Student } from '@/components/types'

export function StudentTrackObjectives({
  student,
}: {
  student: Student
}): JSX.Element | null {
  if (!student.trackObjectives) return null

  return (
    <details className="track-objectives c-details">
      <summary>
        <div className="--summary-inner justify-between select-none">
          Explore {student.handle}&apos;s track goal(s)
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </div>
      </summary>
      <p>{student.trackObjectives}</p>
    </details>
  )
}
