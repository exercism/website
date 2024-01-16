import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { useConfirmation } from '@/hooks/use-confirmation'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { FormButton } from '@/components/common/FormButton'
import { Modal, ModalProps } from './Modal'

type APIResponse = {
  links: {
    home: string
  }
}

const DEFAULT_ERROR = new Error('Unable to delete account')

export const DeleteAccountModal = ({
  handle,
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & {
  handle: string
  endpoint: string
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: JSON.stringify({ handle: handle }),
      })

      return fetch
    },
    {
      onSuccess: (response) => {
        redirectTo(response.links.home)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()
      mutation()
    },
    [mutation]
  )

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(handle)

  return (
    <Modal {...props} className="m-delete-account m-generic-destructive">
      <form data-turbo="false" onSubmit={handleSubmit}>
        <div className="info">
          <h2>You&apos;re about to delete your Exercism account</h2>
          <p>
            <strong>Please read this carefully before continuing.</strong>
          </p>
          <p>
            This is <em>irreversible</em> and will mean you’ll lose everything
            you’ve done on your account.
          </p>
          <hr />
          <p>
            <strong>By deleting your account, you will lose access to:</strong>
          </p>
          <ul>
            <li>All solutions you have submitted</li>
            <li>All mentoring you have received</li>
            <li>All mentoring you have given and any testimonials received.</li>
            <li>All your personal data, which will be deleted</li>
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
          <FormButton
            status={status}
            className="btn-default btn-m"
            type="button"
            onClick={props.onClose}
          >
            Cancel
          </FormButton>

          <FormButton
            type="submit"
            disabled={!isAttemptPass}
            status={status}
            className="btn-primary btn-m"
          >
            Delete account
          </FormButton>
        </div>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
