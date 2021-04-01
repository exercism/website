import React, { useCallback } from 'react'
import { DiscussionStatus } from '../../types'

export const StatusTab = ({
  status,
  currentStatus,
  setStatus,
  children,
}: React.PropsWithChildren<{
  status: DiscussionStatus
  currentStatus: DiscussionStatus
  setStatus: (status: DiscussionStatus) => void
}>): JSX.Element => {
  const handleClick = useCallback(() => {
    setStatus(status)
  }, [setStatus, status])

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={currentStatus === status}
    >
      {children}
    </button>
  )
}
