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
      <form onSubmit={handleSubmit} className="buttons">
        <button type="submit">Delete file</button>
        <button type="button" onClick={handleClose}>
          Cancel
        </button>
      </form>
    </Modal>
  )
}
