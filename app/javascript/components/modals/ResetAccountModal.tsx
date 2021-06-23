import React from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { useConfirmation } from '../../hooks/use-confirmation'

type APIResponse = {
  links: {
    settings: string
  }
}

const DEFAULT_ERROR = new Error('Unable to reset account')

export const ResetAccountModal = ({
  handle,
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & {
  handle: string
  endpoint: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (response) => {
        window.location.replace(response.links.settings)
      },
    }
  )

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(handle)

  return (
    <Modal {...props} className="m-reset-account">
      <form onSubmit={() => mutation()}>
        <h2> Reset your account</h2>
        <div className="info">
          <p>By resetting your account, you will lose:</p>
          <ul>
            <li>All solutions you have submitted</li>
            <li>All mentoring you have received</li>
            <li>All mentoring you have given and any testimonials received.</li>
            <li>
              Any reputation you have earned through mentoring or publishing
              solutions.
            </li>
          </ul>
        </div>
        <h3>Confirm you mean to do this</h3>
        <label htmlFor="confirmation">
          Enter your handle (case sensitive) in the box below
        </label>

        <input
          id="confirmation"
          type="text"
          value={attempt}
          onChange={(e) => setAttempt(e.target.value)}
        />
        <FormButton type="submit" disabled={!isAttemptPass} status={status}>
          Reset account
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
