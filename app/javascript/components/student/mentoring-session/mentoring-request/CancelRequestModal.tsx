import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { MentorSessionRequest } from '@/components/types'

const DEFAULT_ERROR = new Error('Unable to cancel request')

type APIResponse = {
  links: {
    home: string
  }
}

export const CancelRequestModal = ({
  open,
  onClose,
  request,
  ...props
}: Omit<ModalProps, 'className'> & {
  request: MentorSessionRequest
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: request.links.cancel,
        method: 'PATCH',
        body: null,
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

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    onClose()
  }, [status, onClose])

  return (
    <Modal
      open={open}
      onClose={handleClose}
      className="m-generic-confirmation"
      {...props}
    >
      <h3>Cancel mentoring request?</h3>
      <p>
        Are you sure you want to cancel this mentoring request? Please note that
        if someone has started giving feedback in the last few minutes, the
        session may continue regardless of this cancellation.
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton status={status} type="submit" className="btn-primary btn-s">
          Cancel mentoring request
        </FormButton>
        <FormButton
          status={status}
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          Close
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
