import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { Modal } from '../modals'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'
import { redirectTo } from '@/utils/redirect-to'

export type PriceOptionProps = {
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
  displayAmount: number
  paymentIntentType: PaymentIntentType
  period: 'month' | 'year' | 'lifetime'
  paypalLink: string
  premiumRedirectLink: string
}

type PriceCardProps = PriceOptionProps & { onStripeClick: () => void }

export function PriceOption({ data }: { data: PriceOptionProps }): JSX.Element {
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(data.premiumRedirectLink)
  }, [data.premiumRedirectLink])

  const handleModalOpen = useCallback(() => {
    setStripeModalOpen(true)
  }, [])

  return (
    <>
      <PriceCard
        key={data.paymentIntentType}
        {...data}
        onStripeClick={handleModalOpen}
      />
      <Modal
        className="m-premium-stripe-form"
        onClose={() => setStripeModalOpen(false)}
        open={stripeModalOpen}
        theme="dark"
      >
        <ExercismStripeElements>
          <StripeForm
            {...data}
            amount={currency(data.displayAmount)}
            onSuccess={handleSuccess}
          />
        </ExercismStripeElements>
      </Modal>
    </>
  )
}

function PriceCard({ onStripeClick, paypalLink }: PriceCardProps): JSX.Element {
  return (
    <div className="flex flex-col">
      <button onClick={onStripeClick} className="btn-m btn-primary mb-16">
        <span>Use Debit/Credit Card</span>
      </button>
      <a href={paypalLink} className="btn-m btn-secondary">
        <GraphicalIcon
          icon="paypal-light"
          category="graphics"
          className="!filter-none"
        />
        <span>Use PayPal</span>
      </a>
    </div>
  )
}
