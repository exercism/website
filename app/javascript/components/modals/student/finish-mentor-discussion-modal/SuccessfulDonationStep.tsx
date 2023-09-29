import React from 'react'
import currency from 'currency.js'
import { GraphicalIcon } from '@/components/common'
import { BadgeMedallion } from '@/components/common/BadgeMedallion'
import type { BadgeRarity } from '@/components/types'

const badge = { rarity: 'rare' as BadgeRarity, iconName: 'supporter' }

export function SuccessfulDonationStep({
  amount,
  closeLink,
}: {
  amount: currency | null
  closeLink: string
}): JSX.Element {
  return (
    <div className="successful-donation-step flex flex-col items-center text-center">
      <GraphicalIcon
        icon="completed-check-circle"
        height={64}
        width={64}
        className="mb-20"
      />
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

      <a href={closeLink} className="btn-primary btn-l w-[50%]">
        Continue to Exercise
      </a>
    </div>
  )
}
