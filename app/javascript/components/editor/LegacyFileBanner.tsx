import React, { useState, useCallback } from 'react'
import { DeleteFileModal } from './legacy-file-banner/DeleteFileModal'

export const LegacyFileBanner = ({
  onDelete,
}: {
  onDelete: () => void
}): JSX.Element => {
  const [isOpen, setIsOpen] = useState(false)

  const handleOpen = useCallback(() => {
    setIsOpen(true)
  }, [])

  const handleClose = useCallback(() => {
    setIsOpen(false)
  }, [])

  return (
    <React.Fragment>
      <div>
        <button onClick={handleOpen}>Delete file</button>
      </div>
      <DeleteFileModal
        open={isOpen}
        onClose={handleClose}
        onDelete={onDelete}
      />
    </React.Fragment>
  )
}
