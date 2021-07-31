import React from 'react'

export const ExistingSubscriptionNotice = ({
  amountInDollars,
  onExtraDonation,
}: {
  amountInDollars: number
  onExtraDonation: () => void
}): JSX.Element => {
  return (
    <React.Fragment>
      <div className="existing-subscription">
        <strong>
          You already donate ${amountInDollars} per month to Exercism. Thank
          you!
        </strong>
        <br />
        To change or manage this go to <a href="#">Donation Settings</a>.
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
