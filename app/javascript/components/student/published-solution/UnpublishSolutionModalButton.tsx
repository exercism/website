import React, { useState } from 'react'
import { UnpublishSolutionModal } from '@/components/modals/UnpublishSolutionModal'
import { inlineButtonClassNames } from './ChangePublishedIterationModalButton'

type Links = {
  unpublish: string
}

export type UnpublishSolutionModalButtonProps = {
  links: Links
  label: string
}
export default function UnpublishSolutionModalButton({
  links,
  label,
}: UnpublishSolutionModalButtonProps): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button
        className={inlineButtonClassNames}
        onClick={() => setIsOpen(true)}
      >
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
