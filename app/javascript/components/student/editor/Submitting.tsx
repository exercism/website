import React, { useCallback } from 'react'

export function Submitting({ onCancel }: { onCancel: () => void }) {
  const handleCancel = useCallback(
    (e) => {
      onCancel()
    },
    [onCancel]
  )

  return (
    <div>
      <p>Submitting...</p>
      <button type="button" onClick={handleCancel}>
        Cancel
      </button>
    </div>
  )
}
