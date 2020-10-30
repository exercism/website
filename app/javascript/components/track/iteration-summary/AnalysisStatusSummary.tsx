import React from 'react'
import { RepresentationStatus, AnalysisStatus } from '../IterationSummary'

function Content({
  analysisStatus,
  representationStatus,
}: {
  analysisStatus: AnalysisStatus
  representationStatus: RepresentationStatus
}) {
  if (
    analysisStatus === AnalysisStatus.QUEUED ||
    representationStatus === RepresentationStatus.QUEUED
  ) {
    return (
      <>
        <svg role="presentation" className="--icon">
          <use xlinkHref="#loading" />
        </svg>
        <div className="--status">Analysing</div>
      </>
    )
  }

  if (
    analysisStatus === AnalysisStatus.NOT_QUEUED &&
    representationStatus === RepresentationStatus.NOT_QUEUED
  ) {
    return <></>
  }

  return (
    <>
      <div className="--dot"></div>
      <div className="--status">Analysed</div>
    </>
  )
}

export function AnalysisStatusSummary({
  analysisStatus,
  representationStatus,
}: {
  analysisStatus: AnalysisStatus
  representationStatus: RepresentationStatus
}) {
  return (
    <div className={`--analyzer --${analysisStatus}`}>
      <Content
        analysisStatus={analysisStatus}
        representationStatus={representationStatus}
      />
    </div>
  )
}
