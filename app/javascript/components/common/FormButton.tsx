import React from 'react'
import { MutationStatus } from '@tanstack/react-query'

export const FormButton = ({
  status,
  children,
  disabled: propDisabled,
  ...props
}: React.PropsWithChildren<
  React.ButtonHTMLAttributes<HTMLButtonElement> & { status: MutationStatus }
>): JSX.Element => {
  const requestDisabled = status === 'loading'

  return (
    <button {...props} disabled={requestDisabled || propDisabled}>
      {children}
    </button>
  )
}
