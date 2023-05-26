import React, { useState } from 'react'
import { PremiumFormOptions } from './subscription-form/PremiumFormOptions'
import {
  PROVIDER_INFO,
  Provider,
  SubscriptionFormProps,
} from './SubscriptionForm'
import { data } from 'autoprefixer'
import currency from 'currency.js'
import { Modal } from '../modals'
import { ExercismStripeElements } from './ExercismStripeElements'
import { StripeForm } from './StripeForm'

type Links = Record<'cancel' | 'insidersPath', string>
type Intervals = 'year' | 'month' | 'lifetime'
type PremiumProviders = Exclude<Provider, 'github'>

const PLANS = ['monthly plan ($9.99/month)', 'annual plan ($99.99/year)']

export type PremiumSubscriptionProps = {
  interval: Intervals
  provider: PremiumProviders
  links: Links
} & Pick<SubscriptionFormProps, 'amount'>

export default ({
  amount,
  links,
  interval,
  provider,
}: PremiumSubscriptionProps): JSX.Element => {
  const currentPlan = PLANS[interval === 'month' ? 0 : 1]
  const otherPlan = PLANS[interval === 'month' ? 1 : 0]
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

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
            You&apos;re currently on the {currentPlan}. If you&apos;d like to
            move to our {otherPlan}, please contact&nbsp;
            <a className="underline" href="mailto:loretta@exercism.org">
              Loretta
            </a>
            .
          </p>
          {provider === 'stripe' ? (
            <PremiumFormOptions amount={amount} links={links} />
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
            &nbsp;and get Premium for free forever, by making a one time
            donation of $499.
          </p>
        </>
      )}
      {/* <Modal
        className="m-premium-stripe-form"
        onClose={() => setStripeModalOpen(false)}
        open={stripeModalOpen}
        theme="dark"
      >
        <ExercismStripeElements>
          <StripeForm
            {...data}
            amount={currency(499)}
            onSuccess={()=>console.log('success!!')}
          />
        </ExercismStripeElements>
      </Modal> */}
    </React.Fragment>
  )
}
