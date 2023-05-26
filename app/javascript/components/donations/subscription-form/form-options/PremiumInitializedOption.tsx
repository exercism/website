import React from 'react'

export const InitializedOption = ({
  onCancelling,
}: {
  onCancelling: () => void
}): JSX.Element => {
  return (
    <div className="options">
      <button type="button" onClick={onCancelling} className="text-a-subtle">
        You can cancel Premium anytime.
      </button>
    </div>
  )
}
