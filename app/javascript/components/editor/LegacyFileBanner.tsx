import React, { useState, useCallback } from 'react'
import { DeleteFileModal } from './legacy-file-banner/DeleteFileModal'
import { ProminentLink, GraphicalIcon } from '../common'

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
      <div className="legacy-file-banner">
        <h3 className="text-15 leading-150 font-semibold">
          This file is unexpected. Did you upload it via the CLI by accident?
        </h3>
        <button
          onClick={handleOpen}
          className="btn-xs btn-secondary mr-24 ml-auto"
        >
          <GraphicalIcon icon="trash" />
          <span>Delete file…</span>
        </button>
        {/* TODO: Power from Rails */}
        <ProminentLink
          link="/docs/using/solving-exercises/legacy-files"
          text="Learn More"
          external={true}
        />
      </div>
      <DeleteFileModal
        open={isOpen}
        onClose={handleClose}
        onDelete={onDelete}
      />
    </React.Fragment>
  )
}
