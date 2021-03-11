import React, { useState, useEffect } from 'react'
import { Iteration } from '../../types'
import { IterationChannel } from '../../../channels/iterationChannel'
import { fromNow } from '../../../utils/time'
import { ProcessingStatusSummary } from '../../track/iteration-summary/ProcessingStatusSummary'

export const IterationHeader = ({
  iteration,
  latest,
}: {
  iteration: Iteration
  latest: boolean
}): JSX.Element => {
  const [status, setStatus] = useState(iteration.status)

  useEffect(() => {
    const iterationChannel = new IterationChannel(
      iteration.uuid,
      (iteration) => {
        setStatus(iteration.status)
      }
    )

    return () => {
      iterationChannel.disconnect()
    }
  }, [iteration])

  return (
    <header className="iteration-header">
      <div className="info">
        <div className="title">
          <h2>Iteration {iteration.idx}</h2>
          {latest ? <div className="latest">latest</div> : null}
          <ProcessingStatusSummary iterationStatus={status} />
        </div>
        <div className="submitted-time">
          <time dateTime={iteration.createdAt}>
            Submitted {fromNow(iteration.createdAt)}
          </time>
        </div>
      </div>
    </header>
  )
}
