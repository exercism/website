import React, { useCallback } from 'react'

export function Submitting({ onCancel }: { onCancel: () => void }) {
  const handleCancel = useCallback(
    (e) => {
      e.preventDefault()
      onCancel()
    },
    [onCancel]
  )

  return (
    <div>
      <p>Submitting...</p>
      <button onClick={handleCancel}>Cancel</button>
    </div>
  )
}
