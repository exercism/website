// i18n-key-prefix:
// i18n-namespace: components/settings/DeleteAccountButton.tsx
import React, { useState } from 'react'
import { DeleteAccountModal } from '../modals/DeleteAccountModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  delete: string
}

export default function DeleteAccountButton({
  handle,
  links,
}: {
  handle: string
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)
  const { t } = useAppTranslation('components/settings/DeleteAccountButton.tsx')

  return (
    <React.Fragment>
      <button
        type="button"
        className="c-delete-account-button btn-alert btn-m"
        onClick={() => setOpen(!open)}
      >
        {t('deleteAccount')}
      </button>
      <DeleteAccountModal
        open={open}
        onClose={() => setOpen(false)}
        handle={handle}
        endpoint={links.delete}
      />
    </React.Fragment>
  )
}
