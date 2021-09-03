import React, { useState, useEffect, useRef } from 'react'
import { Iteration } from '../../../types'
import { IterationChannel } from '../../../../channels/iterationChannel'
import { fromNow } from '../../../../utils/time'
import { GraphicalIcon } from '../../../common'
import { ProcessingStatusButton } from '../../../track/iteration-summary/ProcessingStatusButton'

export const IterationHeader = ({
  iteration: initialIteration,
  isOutOfDate,
}: {
  iteration: Iteration
  isOutOfDate: boolean
}): JSX.Element => {
  const [iteration, setIteration] = useState(initialIteration)
  const channel = useRef<IterationChannel | undefined>()

  useEffect(() => {
    const iterationChannel = new IterationChannel(
      iteration.uuid,
      (iteration) => {
        setIteration(iteration)
      }
    )

    channel.current = iterationChannel

    return () => {
      iterationChannel.disconnect()
    }
  }, [channel, iteration, setIteration])

  useEffect(() => {
    setIteration(initialIteration)
  }, [initialIteration])

  return (
    <header className="iteration-header">
      <div className="c-mentoring-session-iteration-header">
        <div className="--info">
          <div className="--idx">
            <h3>Iteration {iteration.idx}</h3>
            {iteration.isLatest ? (
              <div className="--latest" aria-label="Latest iteration">
                Latest
              </div>
            ) : null}

            {iteration.isPublished ? (
              <div
                className="--published"
                aria-label="This iteration is published"
              >
                Published
              </div>
            ) : null}
          </div>
          <div className="--details">
            Submitted{' '}
            <time dateTime={iteration.createdAt} title={iteration.createdAt}>
              {fromNow(iteration.createdAt)}
            </time>
          </div>
        </div>

        {isOutOfDate ? (
          <div className="--out-of-date">
            <GraphicalIcon icon="warning" />
            <div className="--status">Outdated</div>
          </div>
        ) : null}

        <ProcessingStatusButton iteration={iteration} />
      </div>
    </header>
  )
}
