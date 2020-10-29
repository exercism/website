import React, { useEffect, useState, useRef } from 'react'
import { TestRunStatus } from '../student/Editor'
import { fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { TestsStatusSummary } from './iteration-summary/TestsStatusSummary'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'
import { IterationsChannel } from '../../channels/iterationsChannel'

export type Iteration = {
  id: number
  idx: number
  submissionMethod: SubmissionMethod
  createdAt: Date
  testsStatus: TestRunStatus
  representationStatus: RepresentationStatus
  analysisStatus: AnalysisStatus
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

export function IterationSummary(props: { iteration: Iteration }) {
  const [iteration, setIteration] = useState(props.iteration)
  const submissionMethodLabels = {
    [SubmissionMethod.CLI]: 'CLI',
    [SubmissionMethod.API]: 'API',
  }
  const channel = useRef<IterationsChannel | undefined>()

  useEffect(() => {
    channel.current = new IterationsChannel(iteration, (iteration) => {
      setIteration(iteration)
    })

    return () => {
      channel.current?.disconnect()
    }
  }, [iteration])

  useEffect(() => {
    return () => {
      channel.current?.disconnect()
    }
  }, [channel])

  return (
    <div className="header">
      <SubmissionMethodIcon submissionMethod={iteration.submissionMethod} />
      <div className="info">
        <div className="idx">
          <h3>Iteration {iteration.idx}</h3>
          <div className="dot"></div>
          <div className="latest">Latest</div>
        </div>
        <div className="details" role="details">
          Submitted via {submissionMethodLabels[iteration.submissionMethod]},{' '}
          {fromNow(iteration.createdAt)}
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
