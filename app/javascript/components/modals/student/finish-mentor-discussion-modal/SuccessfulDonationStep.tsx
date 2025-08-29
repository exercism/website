import React from 'react'
import currency from 'currency.js'
import { GraphicalIcon } from '@/components/common'
import { BadgeMedallion } from '@/components/common/BadgeMedallion'
import type { BadgeRarity } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const badge = { rarity: 'rare' as BadgeRarity, iconName: 'supporter' }

export function SuccessfulDonationStep({
  amount,
  closeLink,
}: {
  amount: currency | null
  closeLink: string
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  return (
    <div className="successful-donation-step flex flex-col items-center text-center">
      <GraphicalIcon
        icon="completed-check-circle"
        height={64}
        width={64}
        className="mb-20"
      />
      <h2 className="text-h3 mb-8">
        {t('successfulDonationStep.youveDonatedSuccessfully', {
          amount: amount?.format(),
        })}
      </h2>
      <p className="text-p-large mb-24">
        {t('successfulDonationStep.trulyAppreciateSupport')}
      </p>
      <div className="badge-container">
        <BadgeMedallion badge={badge} />
        <div className="text-textColor2 text-18 leading-150">
          <Trans
            ns="components/donations"
            i18nKey="successfulDonationStep.youVeEarnedTheBadge"
            components={[<strong className="font-medium" />]}
          />
        </div>
      </div>

      <a href={closeLink} className="btn-primary btn-l w-[50%]">
        {t('successfulDonationStep.continueToExercise')}
      </a>
    </div>
  )
}
