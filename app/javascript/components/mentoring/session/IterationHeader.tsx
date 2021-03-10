import React, { useState, useEffect } from 'react'
import { Iteration } from '../../types'
import { IterationChannel } from '../../../channels/iterationChannel'
import { fromNow } from '../../../utils/time'

export const IterationHeader = ({
  iteration,
  latest,
}: {
  iteration: Iteration
  latest: boolean
}): JSX.Element => {
  const [testsStatus, setTestsStatus] = useState(iteration.testsStatus)

  useEffect(() => {
    const iterationChannel = new IterationChannel(
      iteration.uuid,
      (iteration) => {
        setTestsStatus(iteration.testsStatus)
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
          <div className="tests-status">{testsStatus}</div>
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
