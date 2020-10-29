import React from 'react'
import { RepresenterStatus, AnalyzerStatus } from '../IterationSummary'

function Content({
  analyzerStatus,
  representerStatus,
}: {
  analyzerStatus: AnalyzerStatus
  representerStatus: RepresenterStatus
}) {
  if (
    analyzerStatus === AnalyzerStatus.QUEUED ||
    representerStatus === RepresenterStatus.QUEUED
  ) {
    return (
      <>
        <svg role="presentation" className="icon">
          <use xlinkHref="#loading" />
        </svg>
        <div className="status">Analysing</div>
      </>
    )
  }

  return (
    <>
      <div className="dot"></div>
      <div className="status">Analysed</div>
    </>
  )
}

export function AnalysisStatus({
  analyzerStatus,
  representerStatus,
}: {
  analyzerStatus: AnalyzerStatus
  representerStatus: RepresenterStatus
}) {
  return (
    <div className="analyzer">
      <Content
        analyzerStatus={analyzerStatus}
        representerStatus={representerStatus}
      />
    </div>
  )
}
