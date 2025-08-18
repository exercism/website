import React from 'react'
import currency from 'currency.js'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  settings: string
}

export const ExistingSubscriptionNotice = ({
  amount,
  onExtraDonation,
  links,
}: {
  amount: currency
  onExtraDonation: () => void
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation('components/donations')
  return (
    <React.Fragment>
      <div className="existing-subscription">
        <strong>
          {t(
            'existingSubscriptionNotice.youAlreadyDonatePerMonthToExercismThankYou',
            {
              amount: amount.format(),
            }
          )}
        </strong>{' '}
        {t(
          'existingSubscriptionNotice.toChangeOrManageThisGoToDonationSettings',
          {
            donationSettingsLink: (
              <a href={links.settings}>Donation Settings</a>
            ),
          }
        )}
      </div>
      <div className="extra-cta">
        {t('existingSubscriptionNotice.extra')}{' '}
        <button type="button" onClick={onExtraDonation}>
          {t('existingSubscriptionNotice.oneTimeDonations')}
        </button>{' '}
        {t('existingSubscriptionNotice.areStillGratefullyReceived')}!
      </div>
      <div className="form-cover" />
    </React.Fragment>
  )
}
