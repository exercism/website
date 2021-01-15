import React from 'react'
import { Loading } from '../../common'
import { useMutation } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'

type ComponentProps = {
  endpoint: string
  onSuccess: () => void
  onMouseLeave: () => void
}

export const RemoveFavoriteButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const DEFAULT_ERROR = new Error('Unable to remove student as a favorite')

const Component = ({
  endpoint,
  onSuccess,
  ...props
}: ComponentProps): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(() => {
    return sendRequest({
      endpoint: endpoint,
      method: 'DELETE',
      body: null,
      isMountedRef: isMountedRef,
    }).then(onSuccess)
  })

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button
          {...props}
          onClick={() => {
            mutation()
          }}
          type="button"
          className="btn-small"
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
