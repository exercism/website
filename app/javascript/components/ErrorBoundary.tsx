import React, { useEffect } from 'react'
import {
  ErrorBoundary as ReactErrorBoundary,
  FallbackProps,
  useErrorHandler as useReactErrorHandler,
  ErrorBoundaryPropsWithComponent,
} from 'react-error-boundary'
import { APIError } from './types'

const ERROR_MESSAGE_TIMEOUT_IN_MS = 500

type ErrorBoundaryType = Omit<
  ErrorBoundaryPropsWithComponent,
  'FallbackComponent'
> & { FallbackComponent?: React.ComponentType<FallbackProps> }

export const ErrorBoundary = ({
  children,
  FallbackComponent = ErrorFallback,
  ...props
}: React.PropsWithChildren<ErrorBoundaryType>): JSX.Element => {
  return (
    <ReactErrorBoundary FallbackComponent={FallbackComponent} {...props}>
      {children}
    </ReactErrorBoundary>
  )
}

const ErrorFallback = ({ error, resetErrorBoundary }: FallbackProps) => {
  useEffect(() => {
    setTimeout(resetErrorBoundary, ERROR_MESSAGE_TIMEOUT_IN_MS)
  }, [resetErrorBoundary])

  return (
    <div>
      <p>{error.message}</p>
    </div>
  )
}

export const useErrorHandler = (
  error: unknown,
  { defaultError }: { defaultError: Error }
): void => {
  const handler = useReactErrorHandler()

  useEffect(() => {
    if (!error) {
      return
    }

    if (error instanceof Error) {
      handler(defaultError)
    } else if (error instanceof Response) {
      error
        .json()
        .then((res: { error: APIError }) => {
          handler(new Error(res.error.message))
        })
        .catch(() => {
          handler(defaultError)
        })
    }
  }, [defaultError, error, handler])
}
