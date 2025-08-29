import React from 'react'
import currency from 'currency.js'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  useAppTranslation('components/donations')
  return (
    <React.Fragment>
      <div className="existing-subscription">
        <Trans
          i18nKey="existingSubscriptionNotice.youAlreadyDonate"
          ns="components/donations"
          values={{ amount: amount.format() }}
          components={[<strong />, <a href={links.settings} />]}
        />
      </div>
      <div className="extra-cta">
        <Trans
          ns="components/donations"
          i18nKey="existingSubscriptionNotice.extra"
          components={[<button type="button" onClick={onExtraDonation} />]}
        />
      </div>
      <div className="form-cover" />
    </React.Fragment>
  )
}
