// i18n-key-prefix: firstTimeModal
// i18n-namespace: components/modals/profile
import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { Modal } from '../Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  profile: string
}

export default function FirstTimeModal({
  links,
}: {
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const { t } = useAppTranslation('components/modals/profile')

  return (
    <Modal
      open={open}
      onClose={() => {
        setOpen(false)
      }}
      className="m-profile-first-time"
    >
      <header>
        <GraphicalIcon icon="confetti" category="graphics" />
        <h2>{t('firstTimeModal.havePublicProfile')}</h2>
        <p>
          <strong>{t('firstTimeModal.goodJob')}</strong>{' '}
          {t('firstTimeModal.seeSolutions')}
        </p>
      </header>
      <div className="copy-section">
        <h3>{t('firstTimeModal.shareProfile')}</h3>
        <CopyToClipboardButton textToCopy={links.profile} />
      </div>
    </Modal>
  )
}
