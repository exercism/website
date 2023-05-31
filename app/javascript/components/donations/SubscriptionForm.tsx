import React from 'react'
import currency from 'currency.js'
import { FormOptions } from './subscription-form/FormOptions'

type Links = {
  cancel: string
  update: string
}

export type Provider = 'github' | 'paypal' | 'stripe'
type ProviderInfoEntry = Record<'displayName' | 'updateLink', string>
type ProviderInfoKeys = Exclude<Provider, 'stripe'>
type ProviderInfo = Record<ProviderInfoKeys, ProviderInfoEntry>

export const PROVIDER_INFO: ProviderInfo = {
  github: {
    displayName: 'GitHub Sponsors',
    updateLink: 'https://github.com/settings/billing',
  },
  paypal: {
    displayName: 'PayPal',
    updateLink: 'https://www.paypal.com/myaccount/autopay/',
  },
}

export type SubscriptionFormProps = {
  amount: currency
  links: Links
  provider: Provider
}

export default ({
  amount,
  links,
  provider,
}: SubscriptionFormProps): JSX.Element => {
  return (
    <React.Fragment>
      <h2>
        You&apos;re currently donating {amount.format()} each month to Exercism.
      </h2>
      <p className="text-p-base">
        <strong>Thank you!</strong> Regular donations like yours allow us to
        anticipate our cashflow and make responsible decisions about hiring and
        growing Exercism.
      </p>
      {provider === 'stripe' ? (
        <FormOptions amount={amount} links={links} />
      ) : (
        <ExternalDonationManagement
          displayName={PROVIDER_INFO[provider].displayName}
          updateLink={PROVIDER_INFO[provider].updateLink}
        />
      )}
    </React.Fragment>
  )
}

export function ExternalDonationManagement({
  displayName,
  updateLink,
}: ProviderInfoEntry): JSX.Element {
  return (
    <p className="text-p-base">
      Your regular donation is managed by {displayName}. To modify or cancel
      your recurring donation, please use{' '}
      <a className="text-prominentLinkColor" href={updateLink}>
        {displayName} Dashboard.
      </a>
    </p>
  )
}
