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
    case EditorStatus.CREATE_SUBMISSION_FAILED:
      return <p>{error}</p>
    case EditorStatus.REVERT_FAILED:
      return <p>{error}</p>
    default:
      return null
  }
}
