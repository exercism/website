import React, { useState, useCallback } from 'react'
import { User } from '../../types'
import { RemovePhotoModal } from './remove-photo-button/RemovePhotoModal'

type Links = {
  remove: string
}

export const RemovePhotoButton = ({
  onDelete,
  links,
}: {
  onDelete: (user: User) => void
  links: Links
}): JSX.Element => {
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
        Remove photo
      </button>
      <RemovePhotoModal
        endpoint={links.remove}
        open={modalOpen}
        onClose={handleModalClose}
        onSuccess={onDelete}
      />
    </React.Fragment>
  )
}
