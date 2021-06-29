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
        <div className="info">
          <h2>You're about to reset your Exercism account</h2>
          <p>
            <strong>
              Please read this carefully before commiting to reset your account.
            </strong>
          </p>
          <p>
            This is <em>irreversible</em> and will mean you’ll lose everything
            you’ve done on your account.
          </p>
          <hr />
          <p>
            <strong>By resetting your account, you will lose:</strong>
          </p>
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
        <hr />
        <label htmlFor="confirmation">
          To confirm, write your handle <pre>{handle}</pre> in the box below:
        </label>

        <input
          id="confirmation"
          type="text"
          value={attempt}
          onChange={(e) => setAttempt(e.target.value)}
          autoComplete="off"
        />
        <hr />
        <div className="btns">
          <button className="btn-default btn-m">Cancel</button>
          <FormButton
            type="submit"
            disabled={!isAttemptPass}
            status={status}
            className="btn-primary btn-m"
          >
            Reset account
          </FormButton>
        </div>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
