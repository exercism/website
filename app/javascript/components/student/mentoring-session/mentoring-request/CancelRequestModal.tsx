import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../../modals/Modal'
import { FormButton } from '../../../common'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'
import { MentorSessionRequest } from '../../../types'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { redirectTo } from '../../../../utils/redirect-to'

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
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
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
      <h3>Cancel request?</h3>
      <p>Are you sure you want to cancel this request?</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton status={status} type="submit" className="btn-warning btn-s">
          Cancel request
        </FormButton>
        <FormButton
          status={status}
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
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
