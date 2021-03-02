import React, { useEffect, useState, useRef } from 'react'
import { SubmissionTestsStatus } from '../editor/types'
import { fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { ProcessingStatusSummary } from './iteration-summary/ProcessingStatusSummary'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { IterationChannel } from '../../channels/iterationChannel'

export type Iteration = {
  uuid: string
  idx: number
  status: IterationStatus
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
  submissionMethod: SubmissionMethod
  createdAt: Date
  testsStatus: SubmissionTestsStatus
  links: IterationLinks
}

type IterationLinks = {
  self: string
}

export enum IterationStatus {
  TESTING = 'testing',
  TESTS_FAILED = 'tests_failed',
  ANALYZING = 'analyzing',
  ESSENTIAL_AUTOMATED_FEEDBACK = 'essential_automated_feedback',
  ACTIONABLE_AUTOMATED_FEEDBACK = 'actionable_automated_feedback',
  NON_ACTIONABLE_AUTOMATED_FEEDBACK = 'non_actionable_automated_feedback',
  NO_AUTOMATED_FEEDBACK = 'no_automated_feedback',
}

export enum SubmissionMethod {
  CLI = 'cli',
  API = 'api',
}

export enum RepresentationStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum AnalysisStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

const SUBMISSION_METHOD_LABELS = {
  [SubmissionMethod.CLI]: 'CLI',
  [SubmissionMethod.API]: 'API',
}

export function IterationSummary(props: {
  iteration: Iteration
  className: null
}): JSX.Element {
  const [iteration, setIteration] = useState(props.iteration)
  const [className, setClassName] = useState(props.className)
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

          {/* TODO: Implement this: https://github.com/exercism/v3-project-management/issues/121 */}
          {true ? (
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
            {fromNow(iteration.createdAt)}
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
        {fromNow(iteration.createdAt)}
      </time>
    </div>
  )
}
