import React from 'react'
import { Loading } from './common/Loading'
import { MutationStatus } from '@tanstack/react-query'
import { ErrorBoundary, useErrorHandler, ErrorFallback } from './ErrorBoundary'
import { FallbackProps } from 'react-error-boundary'

const ErrorMessage = ({
  error,
  defaultError,
}: {
  error: Error | unknown
  defaultError: Error
}) => {
  useErrorHandler(error, { defaultError: defaultError })

  return null
}

export const FetchingBoundary = ({
  status,
  error,
  defaultError,
  children,
  FallbackComponent = ErrorFallback,
  LoadingComponent = Loading,
}: React.PropsWithChildren<{
  status: MutationStatus
  error: Error | unknown
  defaultError: Error
  FallbackComponent?: React.ComponentType<FallbackProps>
  LoadingComponent?: React.ComponentType
}>): JSX.Element | null => {
  switch (status) {
    case 'loading':
      return <LoadingComponent />
    case 'success':
      return <React.Fragment>{children}</React.Fragment>
    default:
      return (
        <ErrorBoundary FallbackComponent={FallbackComponent}>
          <ErrorMessage error={error} defaultError={defaultError} />
        </ErrorBoundary>
      )
  }
}
