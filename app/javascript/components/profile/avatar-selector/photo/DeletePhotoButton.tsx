import React, { useState, useCallback } from 'react'
import { DeletePhotoModal } from './delete-photo-button/DeletePhotoModal'
import { User } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  delete: string
}

export const DeletePhotoButton = ({
  onDelete,
  links,
}: {
  onDelete: (user: User) => void
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/avatar-selector/photo')
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <button type="button" onClick={handleModalOpen}>
        {t('deletePhotoButton.deleteYourPicture')}
      </button>
      <DeletePhotoModal
        endpoint={links.delete}
        open={modalOpen}
        onClose={handleModalClose}
        onSuccess={onDelete}
      />
    </React.Fragment>
  )
}
