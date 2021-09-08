import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../../../modals/Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../../utils/send-request'
import { typecheck } from '../../../../../utils/typecheck'
import { User } from '../../../../types'
import { FormButton } from '../../../../common'
import { ErrorBoundary, ErrorMessage } from '../../../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to remove photo')

export const DeletePhotoModal = ({
  endpoint,
  onClose,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: (user: User) => void
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: null,
      })

      return fetch.then((json) => typecheck<User>(json, 'user'))
    },
    {
      onSuccess: (user) => {
        onSuccess(user)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
      onClose()
    },
    [mutation, onClose]
  )

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    onClose()
  }, [onClose, status])

  return (
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>Delete your profile picture?</h3>
      <p>
        Are you sure you want to delete your photo? Other users will see a
        placeholder picture instead. You can upload a new picture at any time.
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton status={status} type="submit" className="btn-primary btn-s">
          Delete picture
        </FormButton>
        <FormButton
          status={status}
          onClick={handleClose}
          type="button"
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
