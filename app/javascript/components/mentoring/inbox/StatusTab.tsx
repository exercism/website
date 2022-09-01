import React, { useCallback } from 'react'

type StatusTabProps<S> = React.PropsWithChildren<{
  status: S
  currentStatus: S
  setStatus: (status: S) => void
}>

export function StatusTab<T>({
  status,
  currentStatus,
  setStatus,
  children,
}: StatusTabProps<T>): JSX.Element {
  const handleClick = useCallback(() => {
    setStatus(status)
  }, [setStatus, status])

  const selected = currentStatus === status
  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={selected}
      className={`c-tab ${selected ? 'selected' : null}`}
    >
      {children}
    </button>
  )
}
