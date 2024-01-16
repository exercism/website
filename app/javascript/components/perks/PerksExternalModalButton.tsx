import React, { useCallback, useState } from 'react'
import { Modal } from '../modals'

type PerkKeys = 'offerSummaryHtml' | 'offerDetails'
type Links = 'logIn' | 'signUp'
export type PerksExternalModalButtonProps = {
  text: string
  perk: Record<PerkKeys, string>
  links: Record<Links, string>
}
export default function PerksExternalModalButton({
  data,
}: {
  data: PerksExternalModalButtonProps
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(false)

  const closeModal = useCallback(() => {
    setIsModalOpen(false)
  }, [])

  const openModal = useCallback(() => {
    setIsModalOpen(true)
  }, [])

  const { text, perk, links } = data

  return (
    <>
      <button className="btn-m btn-primary" onClick={openModal}>
        {text}
      </button>

      <Modal open={isModalOpen} onClose={closeModal}>
        <PerkExternalModal perk={perk} links={links} onClose={closeModal} />
      </Modal>
    </>
  )
}

type PerkExternalModalProps = Pick<
  PerksExternalModalButtonProps,
  'perk' | 'links'
> & {
  onClose: () => void
}

function PerkExternalModal({ links }: PerkExternalModalProps) {
  return (
    <div className="max-w-[500px] flex flex-col items-center text-center">
      <h2 className="text-p-xlarge font-semibold mb-8">
        Claim this Perk with an Exercism account!
      </h2>
      <p className="text-p-base mb-20">
        Exercism is a not-for-profit organisation. We provide world-class
        education, a great community, and Perks from our partners. Join Exercism
        today. It&apos;s free!
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
