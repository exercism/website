import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const DeleteFileModal = ({
  onDelete,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  onDelete: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/editor/legacy-file-banner')

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
      <h3>{t('deleteFileModal.areYouSure')}</h3>
      <p>{t('deleteFileModal.deletingFile')}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <button type="submit" className="btn-warning btn-s">
          {t('deleteFileModal.deleteFile')}
        </button>
        <button
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          {t('deleteFileModal.cancel')}
        </button>
      </form>
    </Modal>
  )
}
