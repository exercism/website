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
      return <p className="editor-status">Error: {error}</p>
    case EditorStatus.REVERT_FAILED:
      return <p className="editor-status">Error: {error}</p>
    case EditorStatus.REVERTING:
      return <p className="editor-status">Reverting files…</p>
    default:
      return null
  }
}
