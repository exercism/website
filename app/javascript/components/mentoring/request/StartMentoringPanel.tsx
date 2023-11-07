import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { MentorSessionRequest as Request } from '../../types'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to lock solution')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export const StartMentoringPanel = ({
  request,
  onLock,
}: {
  request: Request
  onLock: (request: Request) => void
}): JSX.Element => {
  const {
    mutate: lock,
    status,
    error,
  } = useMutation<Request>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: request.links.lock,
        body: null,
        method: 'PATCH',
      })

      return fetch.then((json) => typecheck<Request>(json, 'request'))
    },
    {
      onSuccess: (request) => onLock(request),
    }
  )

  return (
    <section className="comment-section --lock">
      <h2>
        Help {request.student.handle} write better {request.track.title}?
      </h2>
      <p>
        Feel you can help {request.student.handle} approach this in a better
        way? Start mentoring and show them the way to code bliss.
      </p>
      <button
        type="button"
        onClick={() => lock()}
        disabled={status === 'loading'}
        className="btn-primary btn-m"
      >
        Start mentoring
      </button>
      <div className="note">
        You have 30 minutes until the session returns to the queue for others to
        mentor.
      </div>
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </section>
  )
}
