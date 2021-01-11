import React, { useEffect } from 'react'
import { useMutation } from 'react-query'
import { Loading } from '../../common'
import {
  ErrorBoundary,
  useErrorHandler,
  FallbackProps,
} from 'react-error-boundary'
import { APIError } from '../../types'

type ComponentProps = {
  endpoint: string
}

const ERROR_MESSAGE_TIMEOUT = 500

export const MarkAsNothingToDoButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const ErrorFallback = ({ error, resetErrorBoundary }: FallbackProps) => {
  useEffect(() => {
    setTimeout(resetErrorBoundary, ERROR_MESSAGE_TIMEOUT)
  }, [resetErrorBoundary])

  return (
    <div>
      <p>{error.message}</p>
    </div>
  )
}

const Component = ({ endpoint }: ComponentProps): JSX.Element | null => {
  const handleError = useErrorHandler()
  const [mutation, { status, error }] = useMutation(() => {
    return fetch(endpoint, { method: 'PATCH' }).then((response) => {
      if (!response.ok) {
        throw response
      }
    })
  })

  useEffect(() => {
    if (!error) {
      return
    }

    if (error instanceof Error) {
      handleError(new Error('Unable to mark discussion as nothing to do'))
    } else if (error instanceof Response) {
      error.json().then((res: { error: APIError }) => {
        handleError(new Error(res.error.message))
      })
    }
  }, [error, handleError])

  switch (status) {
    case 'idle':
      return (
        <button
          onClick={() => {
            mutation()
          }}
          type="button"
        >
          Mark as nothing to do
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
