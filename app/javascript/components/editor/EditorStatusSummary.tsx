import React from 'react'
import { EditorStatus } from '../Editor'

export const EditorStatusSummary = ({
  status,
  onCancel,
  error,
}: {
  status: EditorStatus
  onCancel: () => void
  error: string | undefined
}) => {
  switch (status) {
    case EditorStatus.CREATING_SUBMISSION:
      return (
        <div>
          <p>Running tests...</p>
          <button type="button" onClick={onCancel}>
            Cancel
          </button>
        </div>
      )
    case EditorStatus.CREATING_ITERATION:
      return <p>Submitting...</p>
    case EditorStatus.SUBMISSION_CANCELLED:
      return <p>{error}</p>
    default:
      return null
  }
}
