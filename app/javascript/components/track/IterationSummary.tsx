import React, { useEffect, useState, useRef } from 'react'
import { SubmissionTestsStatus } from '../editor/types'
import { fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { TestsStatusSummary } from './iteration-summary/TestsStatusSummary'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { IterationChannel } from '../../channels/iterationChannel'

export type Iteration = {
  uuid: string
  idx: number
  submissionMethod: SubmissionMethod
  createdAt: Date
  testsStatus: SubmissionTestsStatus
  representationStatus: RepresentationStatus
  analysisStatus: AnalysisStatus
  links: IterationLinks
}

type IterationLinks = {
  self: string
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
export function IterationSummary(props: { iteration: Iteration }) {
  const [iteration, setIteration] = useState(props.iteration)
  const channel = useRef<IterationChannel | undefined>()

  useEffect(() => {
    const iterationChannel = new IterationChannel(iteration, (iteration) => {
      setIteration(iteration)
    })

    channel.current = iterationChannel

    return () => {
      iterationChannel.disconnect()
    }
  }, [channel, iteration, setIteration])

  return (
    <div className="c-iteration-summary">
      <SubmissionMethodIcon submissionMethod={iteration.submissionMethod} />
      <div className="--info">
        <div className="--idx">
          <h3>Iteration {iteration.idx}</h3>
          <div className="--dot" role="presentation"></div>
          <div className="--latest" aria-label="Latest iteration">
            Latest
          </div>
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
      <TestsStatusSummary testsStatus={iteration.testsStatus} />
      <AnalysisStatusSummary
        analysisStatus={iteration.analysisStatus}
        representationStatus={iteration.representationStatus}
      />
    </div>
  )
}
