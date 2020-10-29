import React from 'react'
import { TestRunStatus } from '../student/Editor'
import { fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { TestsStatusSummary } from './iteration-summary/TestsStatusSummary'
import { AnalysisStatusSummary } from './iteration-summary/AnalysisStatusSummary'

type Iteration = {
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

export function IterationSummary(props: Iteration) {
  const submissionMethodLabels = {
    [SubmissionMethod.CLI]: 'CLI',
    [SubmissionMethod.API]: 'API',
  }

  return (
    <div className="header">
      <SubmissionMethodIcon submissionMethod={props.submissionMethod} />
      <div className="info">
        <div className="idx">
          <h3>Iteration {props.idx}</h3>
          <div className="dot"></div>
          <div className="latest">Latest</div>
        </div>
        <div className="details" role="details">
          Submitted via {submissionMethodLabels[props.submissionMethod]},{' '}
          {fromNow(props.createdAt)}
        </div>
      </div>
      <TestsStatusSummary testsStatus={props.testsStatus} />
      <AnalysisStatusSummary
        analysisStatus={props.analysisStatus}
        representationStatus={props.representationStatus}
      />
    </div>
  )
}
