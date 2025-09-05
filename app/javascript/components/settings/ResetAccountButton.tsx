import React, { useState } from 'react'
import { ResetAccountModal } from '../modals/ResetAccountModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  reset: string
}

export default function ResetAccountButton({
  handle,
  links,
}: {
  handle: string
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)
  const { t } = useAppTranslation()

  return (
    <React.Fragment>
      <button
        type="button"
        className="c-reset-account-button btn-alert btn-m"
        onClick={() => setOpen(!open)}
      >
        {t('resetAccount')}
      </button>
      <ResetAccountModal
        open={open}
        onClose={() => setOpen(false)}
        handle={handle}
        endpoint={links.reset}
      />
    </React.Fragment>
  )
}
