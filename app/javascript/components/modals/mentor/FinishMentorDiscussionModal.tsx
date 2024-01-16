import React from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { Loading } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { Modal } from '../Modal'

const DEFAULT_ERROR = new Error('Unable to end discussion')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const FinishMentorDiscussionModal = ({
  open,
  onFinish,
  onCancel,
  status,
  error,
  ...props
}: {
  endpoint: string
  open: boolean
  status: MutationStatus
  error: unknown
  onFinish: () => void
  onCancel: () => void
}): JSX.Element => {
  return (
    <Modal
      open={open}
      onClose={onCancel}
      className="m-generic-confirmation"
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
        <FormButton
          type="button"
          className="btn-small-discourage"
          onClick={onCancel}
          status={status}
        >
          Cancel
        </FormButton>
        <FormButton
          type="button"
          className="btn-primary btn-s"
          onClick={onFinish}
          status={status}
        >
          End discussion
        </FormButton>
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
