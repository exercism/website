import React from 'react'
import currency from 'currency.js'

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
  return (
    <React.Fragment>
      <div className="existing-subscription">
        <strong>
          You already donate {amount.format()} per month to Exercism. Thank you!
        </strong>{' '}
        To change or manage this go to{' '}
        <a href={links.settings}>Donation Settings</a>.
      </div>
      <div className="extra-cta">
        Extra{' '}
        <button type="button" onClick={onExtraDonation}>
          one-time donations
        </button>{' '}
        are still gratefully received!
      </div>
      <div className="form-cover" />
    </React.Fragment>
  )
}
