import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { MutateFunction, QueryStatus } from 'react-query'
import { FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to mark all notifications as read')

export const MarkAllNotificationsAsReadModal = ({
  mutation,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  mutation: {
    mutation: MutateFunction<any, unknown, undefined, unknown>
    status: QueryStatus
    error: unknown
  }
}): JSX.Element => {
  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation.mutation()
    },
    [mutation]
  )

  const handleClose = useCallback(() => {
    if (mutation.status === 'loading') {
      return
    }

    onClose()
  }, [mutation.status, onClose])

  return (
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>Are you sure you want to mark all notifications as read?</h3>
      <form onSubmit={handleSubmit} className="buttons">
        <FormButton
          type="submit"
          status={mutation.status}
          className="btn-warning btn-s"
        >
          Continue
        </FormButton>
        <FormButton
          type="button"
          status={mutation.status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          Cancel
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[mutation.status]}>
        <ErrorMessage error={mutation.error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
