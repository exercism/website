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
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (response) => {
        window.location.replace(response.links.home)
      },
    }
  )

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(handle)

  return (
    <Modal {...props} className="m-delete-account">
      <form onSubmit={() => mutation()}>
        <label htmlFor="confirmation">Handle:</label>
        <input
          id="confirmation"
          type="text"
          value={attempt}
          onChange={(e) => setAttempt(e.target.value)}
        />
        <FormButton type="submit" disabled={!isAttemptPass} status={status}>
          Delete account
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
