import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { timeFormat } from '../../../utils/time'

export const IterationMarker = ({
  idx,
  createdAt,
}: {
  idx: number
  createdAt: string
}): JSX.Element => {
  return (
    <div className="iteration-marker">
      <div className="info">
        <GraphicalIcon icon="iteration" />
        <strong>Iteration {idx}</strong>
        was submitted
      </div>
      <time>{timeFormat(createdAt, 'DD MMM YYYY')}</time>
    </div>
  )
}
