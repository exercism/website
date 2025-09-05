import React from 'react'
import currency from 'currency.js'
import { FormOptions } from './subscription-form/FormOptions'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation()
  return (
    <React.Fragment>
      <h2>
        {t('subscriptionForm.youReCurrentlyDonatingEachMonthToExercism', {
          amount: amount.format(),
        })}
      </h2>
      <p className="text-p-base">
        <strong>{t('subscriptionForm.thankYou')}</strong>{' '}
        {t(
          'subscriptionForm.regularDonationsLikeYoursAllowUsToAnticipateOurCashflowAndMakeResponsibleDecisionsAboutHiringAndGrowingExercism'
        )}
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
  const { t } = useAppTranslation()
  return (
    <p className="text-p-base">
      <Trans
        i18nKey="externalDonationManagement.yourRegularDonationIsManagedByToModifyOrCancelYourRecurringDonationPleaseUseDashboard"
        ns="components/donations"
        values={{ displayName }}
        components={[
          <a className="text-prominentLinkColor" href={updateLink} />,
        ]}
      />
    </p>
  )
}
