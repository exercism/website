import React, { useEffect, useState, useRef } from 'react'
import { shortFromNow, fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { ProcessingStatusButton } from './iteration-summary/ProcessingStatusButton'
import { ProcessingStatusSummary } from '../common/ProcessingStatusSummary'
import { IterationChannel } from '../../channels/iterationChannel'
import { Iteration } from '../types'

const SUBMISSION_METHOD_LABELS = {
  cli: 'CLI',
  api: 'API',
}

type IterationSummaryProps = {
  iteration: Iteration
  className?: string
  isLatest: boolean
  showSubmissionMethod: boolean
  showTestsStatusAsButton: boolean
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
  isLatest,
  showSubmissionMethod,
  showTestsStatusAsButton,
}: IterationSummaryProps): JSX.Element {
  return (
    <div className={`c-iteration-summary ${className}`}>
      {showSubmissionMethod ? (
        <SubmissionMethodIcon submissionMethod={iteration.submissionMethod} />
      ) : null}
      <div className="--info">
        <div className="--idx">
          <h3>Iteration {iteration.idx}</h3>
          <div className="--dot" role="presentation"></div>
          {isLatest ? (
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
        <div className="--details" data-testid="details">
          Submitted{' '}
          {showSubmissionMethod
            ? `via ${SUBMISSION_METHOD_LABELS[iteration.submissionMethod]}, `
            : null}
          <time
            dateTime={iteration.createdAt.toString()}
            title={iteration.createdAt.toString()}
          >
            {fromNow(iteration.createdAt)}
          </time>
        </div>
      </div>
      {showTestsStatusAsButton ? (
        <ProcessingStatusButton iteration={iteration} />
      ) : (
        <ProcessingStatusSummary iterationStatus={iteration.status} />
      )}
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
