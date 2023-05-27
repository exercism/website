import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { Modal } from '../modals'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'
import { redirectTo } from '@/utils/redirect-to'

type Period = 'month' | 'year' | 'lifetime'

export type PriceOptionProps = {
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
  displayAmount: number
  paymentIntentType: PaymentIntentType
  period: Period
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
        ReactModalClassName="max-w-[570px]"
      >
        {ModalHeader(data.period)}
        <ExercismStripeElements>
          <StripeForm
            {...data}
            amount={currency(data.displayAmount)}
            onSuccess={handleSuccess}
          />
        </ExercismStripeElements>
        {ModalFooter(data.period)}
      </Modal>
    </>
  )
}

function PriceCard({ onStripeClick, paypalLink }: PriceCardProps): JSX.Element {
  return (
    <div className="flex flex-row items-center justify-center gap-12">
      <button onClick={onStripeClick} className="btn-m btn-primary">
        <span>Debit/Credit Card</span>
      </button>
      <a href={paypalLink} className="btn-m btn-secondary">
        <GraphicalIcon
          icon="paypal-light"
          category="graphics"
          className="!filter-none"
        />
        <span>PayPal</span>
      </a>
    </div>
  )
}

function ModalHeader(period: Period): JSX.Element {
  return (
    <>
      <GraphicalIcon icon="premium" className="w-[48px] h-[48px] mb-16" />
      <h2 className="text-h2 mb-2 !text-white">Exercism Premium</h2>
      <p className="text-p-large mb-20 !text-white">
        Congratulations on upgrading to Exercism Premium. Please enter your card
        details below to get started.
      </p>
      <hr className="mb-32 border-borderColor5 -mx-48" />
    </>
  )
}

function ModalFooter(period: Period): JSX.Element {
  return (
    <p className="text-p-small mt-20">
      All payments are handled securely via Stripe. You can cancel your
      subscription through Settings at any time.
    </p>
  )
}
