import React from 'react'
import { Modal } from '../modals/Modal'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { BadgeRarity } from '../types'

import currency from 'currency.js'

const badge = { rarity: 'rare' as BadgeRarity, iconName: 'supporter' }

export default ({
  amount,
  open,
  closeLink,
}: {
  amount: currency | null
  open: boolean
  closeLink: string
}) => {
  return (
    <Modal open={open} onClose={() => null} className="m-donation-confirmation">
      <GraphicalIcon icon="completed-check-circle" className="main-icon" />
      <h2 className="text-h3 mb-8">
        You’ve donated {amount?.format()} successfully - thank you 💙
      </h2>
      <p className="text-p-large mb-24">
        We truly appreciate your support. Exercism would not be possible without
        awesome contributors like yourself. You’ll be sent an email shortly with
        your donation confirmation and receipt.
      </p>
      <div className="flex items-center rounded-5 shadow-xsZ1 py-6 px-24 bg-lightOrange mb-32 border-1 border-lightGold">
        <BadgeMedallion badge={badge} />
        <div className="text-textColor2 text-18 leading-150">
          You’ve earned the <strong className="font-medium"> Supporter</strong>{' '}
          badge!
        </div>
      </div>

      <a href={closeLink} className="btn-primary btn-l w-100">
        Happy to help! I&apos;m done here 👍
      </a>
    </Modal>
  )
}
