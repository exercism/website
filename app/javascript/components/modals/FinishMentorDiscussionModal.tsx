import React from 'react'
import { Modal } from './Modal'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { Loading } from '../common'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'
import { StudentMentorRelationship } from '../mentoring/Solution'

type Discussion = {
  relationship: StudentMentorRelationship
}

const DEFAULT_ERROR = new Error('Unable to end discussion')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const FinishMentorDiscussionModal = ({
  endpoint,
  open,
  onSuccess,
  onCancel,
  ...props
}: {
  endpoint: string
  open: boolean
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
    <Modal
      open={open}
      onClose={() => {}}
      className="m-finish-mentor-discussion"
      {...props}
    >
      <h3>Are you sure you want to end this discussion?</h3>
      <p>
        It&apos;s normally time to end a discussion when the student has got
        what they wanted from the conversation, or you have taken the
        conversation as far as you like. It&apos;s generally polite to leave the
        student a final goodbye.
      </p>
      <div className="buttons">
        <button
          type="button"
          className="btn-small-discourage"
          onClick={() => onCancel()}
          disabled={status === 'loading'}
        >
          Cancel
          <div className="kb-shortcut">F2</div>
        </button>
        <button
          type="button"
          className="btn-small-cta"
          onClick={() => mutation()}
          disabled={status === 'loading'}
        >
          End discussion
          <div className="kb-shortcut">F3</div>
        </button>
      </div>

      {status === 'loading' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </Modal>
  )
}
