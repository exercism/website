// i18n-key-prefix: perksExternalModalButton
// i18n-namespace: components/perks
import React, { useCallback, useState } from 'react'
import { Modal } from '../modals'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/perks')
  return (
    <div className="max-w-[500px] flex flex-col items-center text-center">
      <h2 className="text-p-xlarge font-semibold mb-8">
        {t('perksExternalModalButton.claimPerk')}
      </h2>
      <p className="text-p-base mb-20">
        {t('perksExternalModalButton.exercismIsNonProfit')}
      </p>
      <div className="flex gap-12">
        <a href={links.signUp} className="btn-m btn-primary">
          {t('perksExternalModalButton.signUp')}
        </a>
        <a href={links.logIn} className="btn-m btn-enhanced">
          {t('perksExternalModalButton.logIn')}
        </a>
      </div>
    </div>
  )
}
