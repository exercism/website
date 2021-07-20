import React from 'react'
import { EditorStatus } from '../Editor'

export const EditorStatusSummary = ({
  status,
  error,
}: {
  status: EditorStatus
  error: string | undefined
}) => {
  switch (status) {
    case EditorStatus.CREATING_ITERATION:
      return <p>Submitting...</p>
    case EditorStatus.SUBMISSION_CANCELLED:
      return <p>{error}</p>
    case EditorStatus.REVERT_FAILED:
      return <p>{error}</p>
    case EditorStatus.REVERTING:
      return <p>Reverting files...</p>
    default:
      return null
  }
}
