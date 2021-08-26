import React, { useState, useCallback } from 'react'
import { MentorSessionRequest } from '../../../types'
import { CancelRequestModal } from './CancelRequestModal'

export const CancelRequestButton = ({
  request,
}: {
  request: MentorSessionRequest
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
        Cancel Request
      </button>
      <CancelRequestModal
        open={modalOpen}
        request={request}
        onClose={handleModalClose}
      />
    </React.Fragment>
  )
}
