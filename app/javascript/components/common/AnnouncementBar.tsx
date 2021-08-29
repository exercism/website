import React, { useState, useCallback } from 'react'
import { AnnouncementModal } from './announcement-bar/AnnouncementModal'

export const AnnouncementBar = ({
  endpoint,
}: {
  endpoint: string
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
        We just launched Exercism V3!
      </button>
      <AnnouncementModal
        open={modalOpen}
        onClose={handleModalClose}
        endpoint={endpoint}
      />
    </React.Fragment>
  )
}
