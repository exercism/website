import React from 'react'
import { Action, EditorStatus } from '../Editor'

export function EditorStatusSummary({
  status,
  dispatch,
}: {
  status?: EditorStatus
  dispatch: (action: Action) => void
}) {
  switch (status) {
    case EditorStatus.SUBMITTING:
      return (
        <div>
          <p>Submitting...</p>
          <button
            onClick={() => {
              dispatch({ type: EditorStatus.SUBMISSION_CANCELLED })
            }}
          >
            Cancel
          </button>
        </div>
      )
    default:
      return <></>
  }
}
