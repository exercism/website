import React, { useCallback, useState } from 'react'
import { Modal } from '@/components/modals'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'

type PerkKeys = 'claimUrl' | 'offerSummaryHtml' | 'offerDetails' | 'voucherCode'
export type PerksModalButtonProps = {
  text: string
  perk: Record<PerkKeys, string>
  partner: Record<'websiteDomain', string>
}
export default function PerksModalButton({
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
        <PerkModal perk={perk} partner={partner} onClose={closeModal} />
      </Modal>
    </>
  )
}

type PerkModalProps = Pick<PerksModalButtonProps, 'perk' | 'partner'> & {
  onClose: () => void
}

function PerkModal({ perk, partner, onClose }: PerkModalProps) {
  return (
    <div className="max-w-[500px]">
      <h2
        dangerouslySetInnerHTML={{ __html: perk.offerSummaryHtml }}
        className="text-p-xlarge font-semibold mb-8"
      />
      <p className="text-p-base mb-20">{perk.offerDetails}</p>
      <div className="mb-20">
        <CopyToClipboardButton textToCopy={perk.voucherCode} />
      </div>

      <div className="flex gap-12">
        <a href={perk.claimUrl} className="btn-m btn-primary">
          Continue to {partner.websiteDomain}
        </a>
        <button className="btn-m btn-enhanced" onClick={onClose}>
          Close
        </button>
      </div>
    </div>
  )
}
