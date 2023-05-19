import React, { useCallback } from 'react'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'
import currency from 'currency.js'
import { useRequestQuery } from '@/hooks'
import { useQueryCache } from 'react-query'

export type PriceOptionsProps = {
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
}

type Props = {
  data: PriceOptionsProps
}

type PriceOption = {
  displayAmount: number
  paymentIntentType: PaymentIntentType
}

type PriceCardProps = PriceOption & PriceOptionsProps

const PRICE_OPTIONS: PriceOption[] = [
  {
    displayAmount: 99.99,
    paymentIntentType: 'premium_yearly_subscription',
  },
  {
    displayAmount: 9.99,
    paymentIntentType: 'premium_monthly_subscription',
  },
  {
    displayAmount: 499.99,
    paymentIntentType: 'premium_lifetime_subscription',
  },
]
export function PriceOptions({ data }: Props): JSX.Element {
  return (
    <div className="flex gap-32 justify-center my-32">
      {PRICE_OPTIONS.map((option) => {
        return (
          <PriceCard
            key={option.paymentIntentType}
            paymentIntentType={option.paymentIntentType}
            displayAmount={option.displayAmount}
            {...data}
          />
        )
      })}
    </div>
  )
}

function PriceCard({
  captchaRequired,
  recaptchaSiteKey,
  userSignedIn,
  paymentIntentType,
  displayAmount,
}: PriceCardProps): JSX.Element {
  return (
    <div className="flex flex-col shadow-base p-24 rounded-16 bg-backgroundColorA mb-16">
      <h2 className="text-h2 mb-32">${displayAmount}/year</h2>

      <a className="btn-m btn-primary mb-16">
        <GraphicalIcon
          icon="stripe"
          category="graphics"
          className="!filter-none"
        />
        <span>Subscribe via Stripe</span>
      </a>
      <a className="btn-m btn-primary">
        <GraphicalIcon
          icon="paypal"
          category="graphics"
          className="!filter-none"
        />
        <span>Subscribe via PayPal</span>
      </a>

      <ExercismStripeElements>
        <StripeForm
          paymentIntentType={paymentIntentType}
          userSignedIn={userSignedIn}
          captchaRequired={captchaRequired}
          recaptchaSiteKey={recaptchaSiteKey}
          amount={currency(displayAmount)}
          onSuccess={(t, a) => console.log(t, a)}
          onProcessing={() => console.log('processing')}
          onSettled={() => console.log('settled')}
        />
      </ExercismStripeElements>
    </div>
  )
}
