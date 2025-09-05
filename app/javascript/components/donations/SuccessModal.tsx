import React from 'react'
import { Modal } from '../modals/Modal'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { BadgeRarity } from '../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

import currency from 'currency.js'
import { Trans } from 'react-i18next'

const badge = { rarity: 'rare' as BadgeRarity, iconName: 'supporter' }

export default function ({
  amount,
  open,
  closeLink,
  handleCloseModal,
}: {
  amount: currency | null
  open: boolean
  closeLink?: string
  handleCloseModal?: () => void
}): JSX.Element {
  const { t } = useAppTranslation()
  return (
    <Modal open={open} onClose={() => null} className="m-donation-confirmation">
      <GraphicalIcon icon="completed-check-circle" className="main-icon" />
      <h2 className="text-h3 mb-8">
        {t('formWithModal.youVeDonatedSuccessfullyThankYou', {
          amount: amount?.format(),
        })}
      </h2>
      <p className="text-p-large mb-24">
        {t(
          'formWithModal.weTrulyAppreciateYourSupportExercismWouldNotBePossibleWithoutAwesomeContributorsLikeYourselfYouLlBeSentAnEmailShortlyWithYourDonationConfirmationAndReceipt'
        )}
      </p>
      <div className="badge-container">
        <BadgeMedallion badge={badge} />
        <div className="text-textColor2 text-18 leading-150">
          <Trans
            i18nKey="formWithModal.youVeEarnedTheBadge"
            components={[<strong className="font-medium" />]}
          />
        </div>
      </div>

      {closeLink ? (
        <a href={closeLink} className="btn-primary btn-l w-100">
          {t('formWithModal.happyToHelpImDoneHere')} 👍
        </a>
      ) : (
        <button onClick={handleCloseModal} className="btn-primary btn-l w-100">
          {t('formWithModal.happyToHelpImDoneHere')} 👍
        </button>
      )}
    </Modal>
  )
}
