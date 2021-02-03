import React from 'react'
import { RepresentationStatus, AnalysisStatus } from '../IterationSummary'
import { GraphicalIcon } from '../../common'
import { Icon } from '../../common/Icon'

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
      <div className="--comments">
        <Icon icon="automated-feedback" alt="Automated feedback comments" />
        <div className="--count">5</div>
      </div>
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
