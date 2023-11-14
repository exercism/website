import React, { useEffect, useState, useRef, useContext } from 'react'
import { shortFromNow, fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { ProcessingStatusButton } from './iteration-summary/ProcessingStatusButton'
import { ProcessingStatusSummary } from '../common'
import { IterationChannel } from '../../channels/iterationChannel'
import { Iteration } from '../types'
import { OutOfDateNotice } from './iteration-summary/OutOfDateNotice'
import { ScreenSizeContext } from '../mentoring/session/ScreenSizeContext'

const SUBMISSION_METHOD_LABELS = {
  cli: 'CLI',
  api: 'Editor',
}

type IterationSummaryProps = {
  iteration: Iteration
  className?: string
  showSubmissionMethod: boolean
  showTimeStamp?: boolean
  showTestsStatusAsButton: boolean
  showFeedbackIndicator: boolean
  OutOfDateNotice?: React.ReactNode
}

export default function IterationSummaryWithWebsockets({
  iteration: initialIteration,
  ...props
}: IterationSummaryProps): JSX.Element {
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
  showSubmissionMethod,
  showTestsStatusAsButton,
  showFeedbackIndicator,
  OutOfDateNotice,
  showTimeStamp = true,
}: IterationSummaryProps): JSX.Element {
  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}
  return (
    <div className={`c-iteration-summary ${className ?? ''}`}>
      {showSubmissionMethod ? (
        <SubmissionMethodIcon submissionMethod={iteration.submissionMethod} />
      ) : null}
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
        <div className="--details" data-testid="details">
          {!isBelowLgWidth && 'Submitted '}
          {showSubmissionMethod
            ? `via ${SUBMISSION_METHOD_LABELS[iteration.submissionMethod]}${
                showTimeStamp ? ',' : ''
              } `
            : null}
          {showTimeStamp && (
            <time
              dateTime={iteration.createdAt.toString()}
              title={iteration.createdAt.toString()}
            >
              {fromNow(iteration.createdAt)}
            </time>
          )}
        </div>
      </div>
      {OutOfDateNotice}

      {showTestsStatusAsButton ? (
        <ProcessingStatusButton iteration={iteration} />
      ) : (
        <ProcessingStatusSummary iterationStatus={iteration.status} />
      )}

      {showFeedbackIndicator ? (
        <AnalysisStatusSummary
          numEssentialAutomatedComments={
            iteration.numEssentialAutomatedComments
          }
          numActionableAutomatedComments={
            iteration.numActionableAutomatedComments
          }
          numNonActionableAutomatedComments={
            iteration.numNonActionableAutomatedComments
          }
        />
      ) : null}
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

IterationSummary.OutOfDateNotice = OutOfDateNotice
