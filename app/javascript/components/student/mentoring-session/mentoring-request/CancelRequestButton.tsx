import React, { useState, useCallback } from 'react'
import { MentorSessionRequest } from '../../../types'
import { CancelRequestModal } from './CancelRequestModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CancelRequestButton = ({
  request,
}: {
  request: MentorSessionRequest
}): JSX.Element => {
  const { t } = useAppTranslation()
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
        {t('cancelRequestButton.cancelRequest')}
      </button>
      <CancelRequestModal
        open={modalOpen}
        request={request}
        onClose={handleModalClose}
      />
    </React.Fragment>
  )
}
