import React from 'react'

export const InitializedOption = ({
  onCancelling,
  onUpdating,
}: {
  onCancelling: () => void
  onUpdating: () => void
}): JSX.Element => {
  return (
    <div className="options">
      <button type="button" onClick={onUpdating} className="text-a-subtle">
        Change amount
      </button>{' '}
      or{' '}
      <button type="button" onClick={onCancelling} className="text-a-subtle">
        cancel your recurring donation
      </button>
    </div>
  )
}
