import React from 'react'
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
  const [mutation, { status, error }] = useMutation(() => {
    const { fetch } = sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: null,
    })

    return fetch
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
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
