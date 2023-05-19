import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'
import { useRequestQuery } from '@/hooks'
import { useQueryCache } from 'react-query'
import { Modal } from '../modals'

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
  period: 'month' | 'year' | 'lifetime'
  favorite?: boolean
}

type PriceCardProps = PriceOption & { onStripeClick: () => void }

const PRICE_OPTIONS: PriceOption[] = [
  {
    displayAmount: 9.99,
    paymentIntentType: 'premium_monthly_subscription',
    period: 'month',
  },
  {
    displayAmount: 99.99,
    paymentIntentType: 'premium_yearly_subscription',
    period: 'year',
    favorite: true,
  },
  {
    displayAmount: 499.99,
    paymentIntentType: 'premium_lifetime_subscription',
    period: 'lifetime',
  },
]
export function PriceOptions({ data }: Props): JSX.Element {
  const [modalOpen, setModalOpen] = useState(false)
  const [selectedOption, setSelectedOption] = useState(PRICE_OPTIONS[0])

  const handleModalOpen = useCallback((option) => {
    setSelectedOption(option)
    setModalOpen(true)
  }, [])

  return (
    <div className="flex gap-32 justify-center my-32">
      {PRICE_OPTIONS.map((option) => {
        return (
          <PriceCard
            key={option.paymentIntentType}
            {...option}
            onStripeClick={() => handleModalOpen(option)}
          />
        )
      })}
      <Modal onClose={() => setModalOpen(false)} open={modalOpen}>
        <ExercismStripeElements>
          <StripeForm
            {...data}
            paymentIntentType={selectedOption.paymentIntentType}
            amount={currency(selectedOption.displayAmount)}
            onSuccess={(t, a) => console.log(t, a)}
            onProcessing={() => console.log('processing')}
            onSettled={() => console.log('settled')}
          />
        </ExercismStripeElements>
      </Modal>
    </div>
  )
}

function PriceCard({
  onStripeClick,
  displayAmount,
  period,
  favorite,
}: PriceCardProps): JSX.Element {
  return (
    <div
      className={`flex flex-col shadow-base p-24 rounded-16 bg-backgroundColorA mb-16 border-2 border-transparent ${
        favorite && 'border-gradient'
      }`}
    >
      <h2 className="text-h2 mb-32">
        ${displayAmount}/{period}
      </h2>

      <button onClick={onStripeClick} className="btn-m btn-primary mb-16">
        <GraphicalIcon
          icon="stripe"
          category="graphics"
          className="!filter-none"
        />
        <span>Subscribe via Stripe</span>
      </button>
      <button className="btn-m btn-primary">
        <GraphicalIcon
          icon="paypal"
          category="graphics"
          className="!filter-none"
        />
        <span>Subscribe via PayPal</span>
      </button>
    </div>
  )
}
