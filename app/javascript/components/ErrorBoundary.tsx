import React, { useEffect } from 'react'
import {
  ErrorBoundary as ReactErrorBoundary,
  FallbackProps,
  useErrorHandler as useReactErrorHandler,
  ErrorBoundaryPropsWithComponent,
} from 'react-error-boundary'
import { APIError } from './types'
import * as Sentry from '@sentry/react'
import {
  isChunkLoadError,
  safeReloadForChunkError,
} from '../utils/chunk-load-error-handler'

const ERROR_MESSAGE_TIMEOUT_IN_MS = 500

type ErrorBoundaryType = Omit<
  ErrorBoundaryPropsWithComponent,
  'FallbackComponent'
> & { FallbackComponent?: React.ComponentType<FallbackProps> }

export const ErrorMessage = ({
  error,
  defaultError,
}: {
  error: Error | unknown
  defaultError: Error
}): null => {
  useErrorHandler(error, { defaultError: defaultError })

  return null
}

const handleError = (error: Error) => {
  if (error.name === 'HandledError') {
    return
  }

  if (error.name === 'AbortError') {
    return
  }

  Sentry.captureException(error)
}

export const ErrorBoundary = ({
  children,
  FallbackComponent = ErrorFallback,
  ...props
}: React.PropsWithChildren<ErrorBoundaryType>): JSX.Element => {
  return (
    <ReactErrorBoundary
      FallbackComponent={FallbackComponent}
      {...props}
      onError={handleError}
    >
      {children}
    </ReactErrorBoundary>
  )
}

export const ErrorFallback = ({
  error,
  resetErrorBoundary,
}: FallbackProps): JSX.Element => {
  useEffect(() => {
    if (isChunkLoadError(error)) {
      safeReloadForChunkError()
      return
    }

    const timer = setTimeout(resetErrorBoundary, ERROR_MESSAGE_TIMEOUT_IN_MS)

    return () => clearTimeout(timer)
  }, [error, resetErrorBoundary])

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
      if (error.name === 'AbortError') {
        return
      }

      if (process.env.NODE_ENV == 'production') {
        Sentry.captureException(error)
      }

      handler(new HandledError(defaultError.message))
    } else if (error instanceof Response) {
      const contentType = error.headers.get('Content-Type')
      const isJson =
        contentType &&
        (contentType.includes('application/json') ||
          contentType.includes('+json'))

      if (isJson) {
        error
          .clone()
          .json()
          .then((res: { error: APIError }) => {
            handler(new HandledError(res.error.message))
          })
          .catch(() => {
            handler(new HandledError(defaultError.message))
          })
      } else {
        handler(new HandledError(defaultError.message))
      }
    }
  }, [defaultError, error, handler])
}

export class HandledError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'HandledError'
  }
}
