import React, { useState } from 'react'
import { UnpublishSolutionModal } from '@/components/modals/UnpublishSolutionModal'

type Links = {
  changeIteration: string
  unpublish: string
}

export type UnpublishSolutionModalButtonProps = {
  links: Links
  label: string
}
export function UnpublishSolutionModalButton({
  links,
  label,
}: UnpublishSolutionModalButtonProps): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button className="inline-block" onClick={() => setIsOpen(true)}>
        {label}
      </button>
      <UnpublishSolutionModal
        endpoint={links.unpublish}
        open={isOpen}
        onClose={() => setIsOpen(false)}
        className="m-unpublish-solution"
      />
    </>
  )
}
