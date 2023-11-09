import React, { useState } from 'react'
import {
  ChangePublishedIterationModal,
  RedirectType,
} from '@/components/modals/ChangePublishedIterationModal'
import { Iteration } from '@/components/types'

type Links = {
  changeIteration: string
}

export type ChangePublishedIterationModalButtonProps = {
  redirectType: RedirectType
  publishedIterationIdx: number | null
  iterations: readonly Iteration[]
  links: Links
  label: string
}

export const inlineButtonClassNames =
  'inline-block text-prominentLinkColor border-b-1 border-prominentLinkColor font-medium'

export default function ChangePublishedIterationModalButton({
  redirectType,
  publishedIterationIdx,
  iterations,
  links,
  label,
}: ChangePublishedIterationModalButtonProps): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button
        className={inlineButtonClassNames}
        onClick={() => setIsOpen(true)}
      >
        {label}
      </button>
      <ChangePublishedIterationModal
        endpoint={links.changeIteration}
        redirectType={redirectType}
        iterations={iterations}
        defaultIterationIdx={publishedIterationIdx}
        open={isOpen}
        onClose={() => setIsOpen(false)}
        className="m-change-published-iteration"
      />
    </>
  )
}
