import React from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'

export const MutationButton = ({
  onClick,
  disabled,
  mutation,
  defaultError,
  children,
}: React.PropsWithChildren<{
  onClick: () => void
  disabled: boolean
  mutation: { status: MutationStatus; error: unknown }
  defaultError: Error
}>): JSX.Element => {
  return (
    <React.Fragment>
      <FormButton
        type="button"
        onClick={onClick}
        disabled={disabled}
        status={mutation.status}
        className="btn-s btn-enhanced"
      >
        {children}
      </FormButton>
      <ErrorBoundary resetKeys={[mutation.status]}>
        <ErrorMessage error={mutation.error} defaultError={defaultError} />
      </ErrorBoundary>
    </React.Fragment>
  )
}
