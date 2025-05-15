import Modal, { ModalProps } from '@/components/modals/Modal'
import React, { useCallback } from 'react'

type ConfirmationModalProps = Omit<ModalProps, 'className'> & {
  title: string
  description?: string
  confirmLabel?: string
  declineLabel?: string
  onConfirm: () => void
  onDecline?: () => void
}

export const ConfirmationModal = ({
  title,
  description,
  confirmLabel = 'Confirm',
  declineLabel = 'Cancel',
  onConfirm,
  onDecline,
  onClose,
  ...props
}: ConfirmationModalProps): JSX.Element => {
  const handleClose = useCallback(() => {
    onDecline?.()
    onClose()
  }, [onClose, onDecline])

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault()
      onConfirm()
    },
    [onConfirm]
  )

  return (
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>{title}</h3>
      {description && <p>{description}</p>}
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <button type="submit" className="btn-warning btn-s">
          {confirmLabel}
        </button>
        <button
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          {declineLabel}
        </button>
      </form>
    </Modal>
  )
}
