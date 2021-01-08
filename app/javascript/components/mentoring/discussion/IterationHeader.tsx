import React from 'react'
import { Iteration } from '../Discussion'
import { GraphicalIcon } from '../../common'
import { fromNow } from '../../../utils/time'

export const IterationHeader = ({
  iteration,
  latest,
}: {
  iteration: Iteration
  latest: boolean
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <div className="info">
        <div className="title">
          <h2>Iteration {iteration.idx}</h2>
          {latest ? <div className="latest">latest</div> : null}
        </div>
        <div className="submitted-time">
          <GraphicalIcon icon="clock" />
          <time>Submitted {fromNow(iteration.createdAt)}</time>
        </div>
      </div>
    </header>
  )
}
