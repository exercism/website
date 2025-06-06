import Modal, { ModalProps } from '@/components/modals/Modal'
import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback } from 'react'

type ConfirmationModalProps = Omit<ModalProps, 'className'> & {
  title: string
  description?: string
  confirmLabel?: string
  declineLabel?: string
  onConfirm: () => void
  onDecline?: () => void
  confirmButtonClass?: string
  isConfirmButtonDisabled?: boolean
}

export const ConfirmationModal = ({
  title,
  description,
  confirmLabel = 'Confirm',
  declineLabel = 'Cancel',
  onConfirm,
  onDecline,
  onClose,
  confirmButtonClass = 'btn-warning',
  isConfirmButtonDisabled = false,
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
        <button
          type="submit"
          className={assembleClassNames('btn-s', confirmButtonClass)}
        >
          {confirmLabel}
        </button>
        <button
          type="button"
          disabled={isConfirmButtonDisabled}
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          {declineLabel}
        </button>
      </form>
    </Modal>
  )
}
