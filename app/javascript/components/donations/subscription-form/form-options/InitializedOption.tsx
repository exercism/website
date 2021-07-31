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
      <button type="button" onClick={onUpdating}>
        Change amount
      </button>{' '}
      or{' '}
      <button type="button" onClick={onCancelling}>
        cancel your recurring donation
      </button>
    </div>
  )
}
