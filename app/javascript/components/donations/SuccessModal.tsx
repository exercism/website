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
}): JSX.Element => {
  return (
    <Modal open={open} onClose={() => null} className="m-donation-confirmation">
      <GraphicalIcon icon="completed-check-circle" className="main-icon" />
      <h2 className="text-h3 mb-8">
        You&apos;ve donated {amount?.format()} successfully - thank you 💙
      </h2>
      <p className="text-p-large mb-24">
        We truly appreciate your support. Exercism would not be possible without
        awesome contributors like yourself. You&apos;ll be sent an email shortly
        with your donation confirmation and receipt.
      </p>
      <div className="badge-container">
        <BadgeMedallion badge={badge} />
        <div className="text-textColor2 text-18 leading-150">
          You&apos;ve earned the{' '}
          <strong className="font-medium"> Supporter</strong> badge!
        </div>
      </div>

      <a href={closeLink} className="btn-primary btn-l w-100">
        Happy to help! I&apos;m done here 👍
      </a>
    </Modal>
  )
}
