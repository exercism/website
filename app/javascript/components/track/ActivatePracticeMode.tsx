import React, { useState } from 'react'
import { ActivatePracticeModeModal } from '../dropdowns/track-menu/ActivatePracticeModeModal'
import { useLogger } from '@/hooks'

export default function ActivatePracticeMode({
  endpoint,
  redirectToUrl,
  buttonLabel,
}: {
  endpoint: string
  buttonLabel: string
  redirectToUrl: string
}): JSX.Element {
  const [modalOpen, setModalOpen] = useState(false)

  return (
    <>
      <button
        className="font-semibold text-prominentLinkColor"
        onClick={() => setModalOpen(true)}
      >
        {buttonLabel}
      </button>
      <ActivatePracticeModeModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        endpoint={endpoint}
        redirectToOnSuccessUrl={redirectToUrl}
      />
    </>
  )
}
