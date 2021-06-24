import React from 'react'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'
import { FallbackProps } from 'react-error-boundary'
import { QueryStatus } from 'react-query'

const ErrorMessage = ({ error }: FallbackProps): JSX.Element => {
  return <span>{error.message}</span>
}

export const FormMessage = ({
  status,
  error,
  defaultError,
  SuccessMessage,
}: {
  status: QueryStatus
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
  status: QueryStatus
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
