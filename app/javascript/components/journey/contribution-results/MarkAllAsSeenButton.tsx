import React from 'react'

export const MarkAllAsSeenButton = ({
  unseenTotal,
  onClick,
}: {
  unseenTotal: number
  onClick: () => void
}): JSX.Element => {
  return (
    <button
      type="button"
      onClick={onClick}
      className="btn-m btn-default"
      disabled={unseenTotal === 0}
    >
      {unseenTotal !== 0
        ? `Mark all ${unseenTotal} as seen`
        : 'Mark all as seen'}
    </button>
  )
}
