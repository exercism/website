import React from 'react'
import { GraphicalIcon } from '../../common'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'

export const IterationLink = ({
  iteration,
}: {
  iteration: Iteration
}): JSX.Element => {
  return (
    <a className="iteration" href={iteration.links.self}>
      <IterationSummary iteration={iteration} showTestsStatusAsButton={false} />
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
