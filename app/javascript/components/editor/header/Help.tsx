import React, { useRef, useState } from 'react'
import { Icon } from '../../common'
import { HelpModal } from '../../modals/HelpModal'

export const Help = ({
  helpHtml,
}: {
  helpHtml: string
}): JSX.Element | null => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)

  return (
    <>
      <HelpModal
        helpHtml={helpHtml}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
      <button
        ref={buttonRef}
        className="help-btn"
        onClick={() => {
          setIsModalOpen(true)
        }}
      >
        <Icon icon="help" alt="Stuck? Get help" />
      </button>
    </>
  )
}
