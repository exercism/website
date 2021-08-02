import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { Iteration } from '../../types'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { typecheck } from '../../../utils/typecheck'

const DEFAULT_ERROR = new Error('Unable to delete iteration')

export const DeleteIterationModal = ({
  iteration,
  onClose,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  iteration: Iteration
  onSuccess: (iteration: Iteration) => void
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: iteration.links.delete,
        method: 'DELETE',
        body: null,
      })

      return fetch.then((json) => typecheck<Iteration>(json, 'iteration'))
    },
    { onSuccess }
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
    <Modal className="m-delete-iteration" onClose={handleClose} {...props}>
      <form onSubmit={handleSubmit}>
        <FormButton type="submit" status={status}>
          Delete iteration
        </FormButton>
        <FormButton type="button" status={status} onClick={handleClose}>
          Cancel
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
