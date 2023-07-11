import React, { useCallback, useState } from 'react'
import { PremiumFormOptions } from './subscription-form/PremiumFormOptions'
import {
  PROVIDER_INFO,
  Provider,
  SubscriptionFormProps,
} from './SubscriptionForm'
import currency from 'currency.js'
import { Modal } from '../modals'
import { ExercismStripeElements } from './ExercismStripeElements'
import { StripeForm } from './StripeForm'
import { redirectTo } from '@/utils/redirect-to'
import { PriceOptionProps } from '../premium/PriceOption'

export type Links = Record<
  | 'cancel'
  | 'updateToMonthly'
  | 'updateToAnnual'
  | 'insidersPath'
  | 'premiumRedirectLink'
  | 'premiumRedirectUrl',
  string
>
type Intervals = 'year' | 'month' | 'lifetime'
type PremiumProviders = Exclude<Provider, 'github'>

export type PremiumPlan = {
  description: string
  type: 'month' | 'year'
  amount: number
}

const PLANS: PremiumPlan[] = [
  { description: 'monthly plan ($9.99/month)', type: 'month', amount: 9.99 },
  { description: 'annual plan ($99.99/year)', type: 'year', amount: 99.99 },
]

export type PremiumSubscriptionProps = {
  interval: Intervals
  provider: PremiumProviders
  links: Links
} & Pick<SubscriptionFormProps, 'amount'> &
  Pick<
    PriceOptionProps,
    'captchaRequired' | 'recaptchaSiteKey' | 'userSignedIn'
  >

export default ({
  links,
  interval,
  provider,
  captchaRequired,
  recaptchaSiteKey,
  userSignedIn,
}: PremiumSubscriptionProps): JSX.Element => {
  const currentPlan = PLANS[interval === 'month' ? 0 : 1]
  const otherPlan = PLANS[interval === 'month' ? 1 : 0]
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(links.premiumRedirectLink)
  }, [links.premiumRedirectLink])

  return (
    <React.Fragment>
      <h2>
        You&apos;re {interval !== 'lifetime' && 'currently'} subscribed to
        Exercism Premium.
      </h2>
      {interval === 'lifetime' ? (
        <p className="text-p-base">
          As an Exercism insider, you get free access to Exercism Premium for
          free. Thank you so much for your support of Exercism.
        </p>
      ) : (
        <>
          <p className="text-p-base">
            You&apos;re currently on the {currentPlan.description}.
          </p>
          {provider === 'stripe' ? (
            <PremiumFormOptions otherPlan={otherPlan} links={links} />
          ) : (
            <p className="text-p-base">
              To cancel your subscription, please use the{' '}
              <a
                className="text-prominentLinkColor"
                href={PROVIDER_INFO['paypal'].updateLink}
              >
                PayPal Dashboard.
              </a>
            </p>
          )}
          <p className="text-p-base mt-12">
            If you&apos;d like even more features, you can join&nbsp;
            <strong>
              <a className="text-prominentLinkColor" href={links.insidersPath}>
                Exercism Insiders
              </a>
            </strong>
            &nbsp;and get Premium for free forever, by making a&nbsp;
            <button
              className="underline"
              onClick={() => setStripeModalOpen(true)}
            >
              one time donation of $499
            </button>
            .
          </p>
        </>
      )}
      <Modal
        className="m-premium-stripe-form"
        onClose={() => setStripeModalOpen(false)}
        open={stripeModalOpen}
        theme="dark"
      >
        <ExercismStripeElements amount={499}>
          <StripeForm
            confirmParamsReturnUrl={links.premiumRedirectUrl}
            paymentIntentType="payment"
            amount={currency(499)}
            captchaRequired={captchaRequired}
            recaptchaSiteKey={recaptchaSiteKey}
            userSignedIn={userSignedIn}
            onSuccess={handleSuccess}
          />
        </ExercismStripeElements>
      </Modal>
    </React.Fragment>
  )
}
