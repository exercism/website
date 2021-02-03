import React from 'react'
import { RepresentationStatus, AnalysisStatus } from '../IterationSummary'
import { GraphicalIcon } from '../../common'

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
        <GraphicalIcon icon="spinner" />
        <div className="--status">Analysing</div>
      </>
    )
  }

  if (
    analysisStatus === AnalysisStatus.NOT_QUEUED &&
    representationStatus === RepresentationStatus.NOT_QUEUED
  ) {
    return null
  }

  return (
    <>
      <div role="presentation" className="--dot"></div>
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
    <div
      className={`--analyzer --${analysisStatus}`}
      role="status"
      aria-label="Analysis status"
    >
      <Content
        analysisStatus={analysisStatus}
        representationStatus={representationStatus}
      />
    </div>
  )
}
