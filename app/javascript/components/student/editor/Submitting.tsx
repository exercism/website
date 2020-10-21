import React from 'react'
import { Action } from '../Editor'

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
          dispatch({ type: 'cancelled' })
        }}
      >
        Cancel
      </button>
    </div>
  )
}
