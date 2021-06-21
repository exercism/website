import React, { useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

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
  const [confirmation, setConfirmation] = useState('')
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

  return (
    <Modal {...props} className="m-delete-account">
      <form onSubmit={() => mutation()}>
        <label htmlFor="confirmation">Handle:</label>
        <input
          id="confirmation"
          type="text"
          value={confirmation}
          onChange={(e) => setConfirmation(e.target.value)}
        />
        <FormButton
          type="submit"
          disabled={handle !== confirmation}
          status={status}
        >
          Delete account
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
