// i18n-key-prefix: deleteProfile
// i18n-namespace: components/settings/DeleteProfileForm.tsx
import React, { useState, useCallback } from 'react'
import { DeleteProfileModal } from './delete-profile-form/DeleteProfileModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  delete: string
}

export default function DeleteProfileForm({
  links,
}: {
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/DeleteProfileForm.tsx')
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <React.Fragment>
      <h2>{t('deleteProfile.deletePublicProfile')}</h2>
      <p className="mb-16 text-p-base">
        {t('deleteProfile.deleteProfileDescription')}
      </p>
      <button
        type="button"
        className="btn-warning btn-m"
        onClick={handleModalOpen}
      >
        {t('deleteProfile.deleteYourProfile')}
      </button>
      <DeleteProfileModal
        open={modalOpen}
        onClose={handleModalClose}
        endpoint={links.delete}
      />
    </React.Fragment>
  )
}
