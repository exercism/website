import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { sendRequest } from '../../../utils/send-request'

type ComponentProps = {
  endpoint: string
}

export const MarkAsNothingToDoButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const DEFAULT_ERROR = new Error('Unable to mark discussion as nothing to do')

const Component = ({ endpoint }: ComponentProps): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(() => {
    return sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: null,
      isMountedRef: isMountedRef,
    })
  })

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button
          onClick={() => {
            mutation()
          }}
          type="button"
          className="btn-keyboard-shortcut"
        >
          <div className="--hint">Remove from Inbox</div>
          <div className="--kb">F2</div>
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
