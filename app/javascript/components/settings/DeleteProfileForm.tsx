import React, { useState, useCallback } from 'react'
import { DeleteProfileModal } from './delete-profile-form/DeleteProfileModal'

type Links = {
  delete: string
}

export default function DeleteProfileForm({
  links,
}: {
  links: Links
}): JSX.Element {
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <h2>Delete your public profile</h2>
      <p className="mb-16 text-p-base">
        This will delete your public profile from the website. You can recreate
        your profile at any time, and the only data that will be deleted is
        links to your social profiles.
      </p>
      <button
        type="button"
        className="btn-warning btn-m"
        onClick={handleModalOpen}
      >
        Delete your profile
      </button>
      <DeleteProfileModal
        open={modalOpen}
        onClose={handleModalClose}
        endpoint={links.delete}
      />
    </React.Fragment>
  )
}
