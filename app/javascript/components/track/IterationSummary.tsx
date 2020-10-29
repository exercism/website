import React from 'react'
import { TestRunStatus } from '../student/Editor'
import { fromNow } from '../../utils/time'
import { SubmissionMethodIcon } from './iteration-summary/SubmissionMethodIcon'
import { TestsStatus } from './iteration-summary/TestsStatus'
import { AnalysisStatus } from './iteration-summary/AnalysisStatus'

type Iteration = {
  idx: number
  submissionMethod: SubmissionMethod
  createdAt: Date
  testsStatus: TestRunStatus
  representerStatus: RepresenterStatus
  analyzerStatus: AnalyzerStatus
}

export enum SubmissionMethod {
  CLI = 'cli',
  API = 'api',
}

export enum RepresenterStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  APPROVED = 'approved',
  DISAPPROVED = 'disapproved',
  INCONCLUSIVE = 'inconclusive',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export enum AnalyzerStatus {
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
      <TestsStatus testsStatus={props.testsStatus} />
      <AnalysisStatus
        analyzerStatus={props.analyzerStatus}
        representerStatus={props.representerStatus}
      />
    </div>
  )
}
