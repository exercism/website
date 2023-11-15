import React from 'react'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'
import { FallbackProps } from 'react-error-boundary'
import { MutationStatus } from '@tanstack/react-query'
import { Icon } from '../common'

const ErrorMessage = ({ error }: FallbackProps): JSX.Element => {
  return (
    <div className="status error">
      <Icon icon="failed-cross-circle" alt="Error" />
      {error.message}
    </div>
  )
}

export const FormMessage = ({
  status,
  error,
  defaultError,
  SuccessMessage,
}: {
  status: MutationStatus
  error: unknown
  defaultError: Error
  SuccessMessage: React.ComponentType<{}>
}): JSX.Element => {
  return (
    <ErrorBoundary FallbackComponent={ErrorMessage} resetKeys={[status]}>
      <Message
        status={status}
        error={error}
        SuccessMessage={SuccessMessage}
        defaultError={defaultError}
      />
    </ErrorBoundary>
  )
}

const Message = ({
  status,
  SuccessMessage,
  defaultError,
  error,
}: {
  status: MutationStatus
  SuccessMessage: React.ComponentType<{}>
  defaultError: Error
  error: unknown
}): JSX.Element | null => {
  useErrorHandler(error, { defaultError: defaultError })

  switch (status) {
    case 'success':
      return <SuccessMessage />
    default:
      return null
  }
}
