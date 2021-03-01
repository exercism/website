import React from 'react'
import { QueryStatus } from 'react-query'

export const FormButton = ({
  status,
  children,
  disabled: propDisabled,
  ...props
}: React.PropsWithChildren<
  React.ButtonHTMLAttributes<HTMLButtonElement> & { status: QueryStatus }
>): JSX.Element => {
  const requestDisabled = status === 'loading'

  return (
    <button {...props} disabled={requestDisabled || propDisabled}>
      {children}
    </button>
  )
}
