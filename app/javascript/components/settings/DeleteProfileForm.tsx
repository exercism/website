import React, { useState, useCallback } from 'react'
import { DeleteProfileModal } from './delete-profile-form/DeleteProfileModal'

type Links = {
  delete: string
}

export const DeleteProfileForm = ({ links }: { links: Links }): JSX.Element => {
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <div>
        <h2>Delete your public profile</h2>
        <p>
          This will delete your public profile from the website. You can always
          bring it back later.
        </p>
        <button
          type="button"
          className="btn-alert btn-m"
          onClick={handleModalOpen}
        >
          Delete your profile
        </button>
      </div>
      <DeleteProfileModal
        open={modalOpen}
        onClose={handleModalClose}
        endpoint={links.delete}
      />
    </React.Fragment>
  )
}
