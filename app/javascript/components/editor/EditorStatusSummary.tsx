import React from 'react'
import { EditorStatus } from './useEditorStatus'

export const EditorStatusSummary = ({
  status,
  error,
}: {
  status: EditorStatus
  error?: string
}): JSX.Element | null => {
  switch (status) {
    case EditorStatus.CREATING_ITERATION:
      return <p>Submitting...</p>
    case EditorStatus.CREATE_SUBMISSION_FAILED:
      return <p>{error}</p>
    case EditorStatus.REVERT_FAILED:
      return <p>{error}</p>
    case EditorStatus.REVERTING:
      return <p>Reverting files...</p>
    default:
      return null
  }
}
