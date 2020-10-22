import React from 'react'
import { Action, EditorStatus } from '../Editor'

export function Submitting({
  dispatch,
}: {
  dispatch: (action: Action) => void
}) {
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
}
