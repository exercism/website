import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback } from 'react'

type StatusTabProps<S> = React.PropsWithChildren<{
  status: S
  currentStatus: S
  setStatus: (status: S) => void
}>

type StatusTabLinkProps<S> = React.PropsWithChildren<{
  status: S
  currentStatus: S
  href: string
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
      className={assembleClassNames('c-tab', selected ? 'selected' : null)}
    >
      {children}
    </button>
  )
}

export function StatusTabLink<T>({
  status,
  currentStatus,
  children,
  href,
}: StatusTabLinkProps<T> & { href: string }): JSX.Element {
  const selected = currentStatus === status

  return (
    <a
      href={href}
      onClick={(e) => selected && e.preventDefault()}
      className={assembleClassNames('c-tab', selected ? 'selected' : null)}
    >
      {children}
    </a>
  )
}
