import React, { useContext } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { MentoringRequest } from '../Solution'
import { RequestContext } from '../request/RequestContext'
import { useIsMounted } from 'use-is-mounted'
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
}: {
  request: MentoringRequest
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { handleRequestLock } = useContext(RequestContext)
  const [lock, { status, error }] = useMutation<MentoringRequest | undefined>(
    () => {
      return sendRequest({
        endpoint: request.links.lock,
        body: null,
        method: 'PATCH',
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<MentoringRequest>(json, 'request')
      })
    },
    {
      onSuccess: (request) => {
        if (!request) {
          return
        }

        handleRequestLock(request)
      },
    }
  )

  return (
    <section className="comment-section">
      <button
        type="button"
        onClick={() => lock()}
        disabled={status === 'loading'}
      >
        Start mentoring
      </button>
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </section>
  )
}
