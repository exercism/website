import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { Discussion } from '../FinishMentorDiscussionModal'
import { typecheck } from '../../../utils/typecheck'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to end discussion')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const AboutToFinishDiscussion = ({
  endpoint,
  onSuccess,
  onCancel,
}: {
  endpoint: string
  onSuccess: (discussion: Discussion) => void
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Discussion>(json, 'discussion')
      })
    },
    {
      onSuccess: (discussion) => {
        if (!discussion) {
          return
        }

        onSuccess(discussion)
      },
    }
  )

  return (
    <div>
      <h1>Are you sure you want to finish this discussion</h1>
      <button
        type="button"
        onClick={() => mutation()}
        disabled={status === 'loading'}
      >
        End discussion
      </button>
      <button
        type="button"
        onClick={() => onCancel()}
        disabled={status === 'loading'}
      >
        Cancel
      </button>
      {status === 'loading' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </div>
  )
}
