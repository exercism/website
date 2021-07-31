import React from 'react'

export const InitializedOption = ({
  onCancelling,
}: {
  onCancelling: () => void
}): JSX.Element => {
  return (
    <div className="options">
      <button>Change amount</button> or{' '}
      <button type="button" onClick={onCancelling}>
        cancel your recurring donation
      </button>
    </div>
  )
}
