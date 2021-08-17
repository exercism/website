import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to mark all as seen')

export const MarkAllAsSeenModal = ({
  endpoint,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: onClose,
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    onClose()
  }, [onClose, status])

  return (
    <Modal
      theme="dark"
      className="m-generic-confirmation"
      onClose={handleClose}
      {...props}
    >
      <h3>Mark all as seen?</h3>
      <p>
        Are you sure you want to mark all as seen? All contributions across all
        pages will be marked as seen.
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-primary btn-s">
          Continue
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          Cancel
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
