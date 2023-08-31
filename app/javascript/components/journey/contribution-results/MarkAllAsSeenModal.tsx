import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { APIResult } from '../ContributionsList'

const DEFAULT_ERROR = new Error('Unable to mark all as seen')

export const MarkAllAsSeenModal = ({
  endpoint,
  onClose,
  onSuccess,
  unseenTotal,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: (response: APIResult) => void
  unseenTotal: number
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResult>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (result) => {
        onSuccess(result)
        onClose()
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
        Are you sure you want to mark all {unseenTotal} contributions as seen?
        Note that these contributions may span multiple pages.
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
