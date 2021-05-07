import React, { useEffect, useState, useRef } from 'react'
import { shortFromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { ProcessingStatusSummary } from '../common/ProcessingStatusSummary'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { IterationChannel } from '../../channels/iterationChannel'
import { Iteration } from '../types'

const SUBMISSION_METHOD_LABELS = {
  cli: 'CLI',
  api: 'API',
}

type IterationSummaryProps = {
  iteration: Iteration
  className?: string
}

export const IterationSummaryWithWebsockets = ({
  iteration: initialIteration,
  ...props
}: IterationSummaryProps): JSX.Element => {
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

  return <IterationSummary iteration={iteration} {...props} />
}

export function IterationSummary({
  iteration,
  className,
}: IterationSummaryProps): JSX.Element {
  return (
    <div className={`c-iteration-summary ${className}`}>
      <SubmissionMethodIcon submissionMethod={iteration.submissionMethod} />
      <div className="--info">
        <div className="--idx">
          <h3>Iteration {iteration.idx}</h3>
          <div className="--dot" role="presentation"></div>
          <div className="--latest" aria-label="Latest iteration">
            Latest
          </div>

          {iteration.isPublished ? (
            <div
              className="--published"
              aria-label="This iteration is published"
            >
              Published
            </div>
          ) : null}
        </div>
        <div className="--details" data-testid="details">
          Submitted via {SUBMISSION_METHOD_LABELS[iteration.submissionMethod]},{' '}
          <time
            dateTime={iteration.createdAt.toString()}
            title={iteration.createdAt.toString()}
          >
            {shortFromNow(iteration.createdAt)}
          </time>
        </div>
      </div>
      <ProcessingStatusSummary iterationStatus={iteration.status} />
      <AnalysisStatusSummary
        numEssentialAutomatedComments={iteration.numEssentialAutomatedComments}
        numActionableAutomatedComments={
          iteration.numActionableAutomatedComments
        }
        numNonActionableAutomatedComments={
          iteration.numNonActionableAutomatedComments
        }
      />
      <time
        dateTime={iteration.createdAt.toString()}
        title={iteration.createdAt.toString()}
        className="--time"
      >
        {shortFromNow(iteration.createdAt)}
      </time>
    </div>
  )
}
