import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { Iteration } from '@/components/types'

export function ReadonlyIterationMarker({
  idx,
}: Pick<Iteration, 'idx'>): JSX.Element {
  return (
    <div className="timeline-entry iteration-entry">
      <div className="timeline-marker">
        <GraphicalIcon icon="iteration" />
      </div>
      <div className="timeline-content">
        <div className="timeline-entry-header">
          <div className="info">
            <strong>Iteration {idx}</strong>
          </div>
        </div>
      </div>
    </div>
  )
}
