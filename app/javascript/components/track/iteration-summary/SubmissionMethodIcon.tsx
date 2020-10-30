import React from 'react'
import { SubmissionMethod } from '../IterationSummary'

export function SubmissionMethodIcon({
  submissionMethod,
}: {
  submissionMethod: SubmissionMethod
}) {
  switch (submissionMethod) {
    case SubmissionMethod.CLI:
      return (
        <svg role="presentation" className="icon upload-method-icon">
          <title>Submitted via CLI</title>
          <use xlinkHref="#cli" />
        </svg>
      )
    case SubmissionMethod.API:
      return (
        <svg role="presentation" className="icon upload-method-icon">
          <title>Submitted via API</title>
          <use xlinkHref="#cli" />
        </svg>
      )
    default:
      return null
  }
}
