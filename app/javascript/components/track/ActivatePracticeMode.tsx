import React, { useState } from 'react'
import { ActivatePracticeModeModal } from '../dropdowns/track-menu/ActivatePracticeModeModal'

export default function ActivatePracticeMode({
  endpoint,
}: {
  endpoint: string
}): JSX.Element {
  const [modalOpen, setModalOpen] = useState(false)
  return (
    <>
      <button
        className="font-bold text-prominentLinkColor"
        onClick={() => setModalOpen(true)}
      >
        disable learning mode.
      </button>
      <ActivatePracticeModeModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        endpoint={endpoint}
      />
    </>
  )
}
