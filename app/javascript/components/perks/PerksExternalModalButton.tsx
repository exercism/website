import React, { useCallback, useState } from 'react'
import { Modal } from '../modals'
import { CopyToClipboardButton } from '../common'

type PerkKeys = 'offerSummaryHtml' | 'offerDetails'
type Links = 'logIn' | 'signUp'
type PerksModalButtonProps = {
  text: string
  perk: Record<PerkKeys, string>
  links: Record<PerkKeys, string>
}
export function PerksModalButton({
  data,
}: {
  data: PerksModalButtonProps
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(false)

  const closeModal = useCallback(() => {
    setIsModalOpen(false)
  }, [])

  const openModal = useCallback(() => {
    setIsModalOpen(true)
  }, [])

  const { text, perk, partner } = data

  return (
    <>
      <button className="btn-m btn-primary" onClick={openModal}>
        {text}
      </button>

      <Modal open={isModalOpen} onClose={closeModal}>
        <PerkExternalModal perk={perk} partner={partner} onClose={closeModal} />
      </Modal>
    </>
  )
}

type PerkExternalModalProps = Pick<PerksModalButtonProps, 'perk' | 'links'> & {
  onClose: () => void
}

function PerkExternalModal({ perk, partner, onClose }: PerkExternalModalProps) {
  return (
    <div className="max-w-[500px]">
      <h2 className="text-p-xlarge font-semibold mb-8">
        Claim this and other Perks with an Exercism account
      </h2>
      <p className="text-p-base mb-20">
        World-class education, a great community, and Perks from our partners.
        Join Exercism today. It's free!
      </p>
      <div className="flex gap-12">
        <a href={links.signUp} className="btn-m btn-primary">
          Sign up
        </a>
        <a href={links.logIn} className="btn-m btn-enhanced">
          Log in
        </a>
      </div>
    </div>
  )
}
