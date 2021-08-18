import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'

export const DeleteFileModal = ({
  onDelete,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  onDelete: () => void
}): JSX.Element => {
  const handleClose = useCallback(() => {
    onClose()
  }, [onClose])

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()
      onDelete()
    },
    [onDelete]
  )

  return (
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>Are you sure you want to delete this file?</h3>
      <p>
        Deleting this file will mean it is not submitted as part of your next
        iteration. However, it will remain visible in your previous iteration.
        If you change your mind before submitting, you can use the "Reset to
        last iteration" button (top-right) to undo this change.
      </p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <button type="submit" className="btn-warning btn-s">
          Delete file
        </button>
        <button
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          Cancel
        </button>
      </form>
    </Modal>
  )
}
