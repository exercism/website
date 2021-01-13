import React, { useEffect } from 'react'
import { Loading } from '../../common'
import { useMutation } from 'react-query'
import {
  ErrorBoundary,
  useErrorHandler,
  FallbackProps,
} from 'react-error-boundary'
import { APIError } from '../../types'

const ERROR_MESSAGE_TIMEOUT = 500

type ComponentProps = {
  endpoint: string
  onSuccess: () => void
}

export const RemoveFavoriteButton = (props: ComponentProps): JSX.Element => {
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

export const Component = ({
  endpoint,
  onSuccess,
}: ComponentProps): JSX.Element | null => {
  const [mutation, { status, error }] = useMutation(() => {
    return fetch(endpoint, { method: 'DELETE' })
      .then((response) => {
        if (!response.ok) {
          throw response
        }

        return response
      })
      .then(onSuccess)
  })
  const handleError = useErrorHandler()

  useEffect(() => {
    if (!error) {
      return
    }

    if (error instanceof Error) {
      handleError(new Error('Unable to remove student as a favorite'))
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
          Unfavorite?
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
