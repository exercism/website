import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { redirectTo } from '@/utils'
import { Modal } from '../modals'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'

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
  insidersRedirectLink: string
}

type PriceCardProps = PriceOptionProps & { onStripeClick: () => void }

export function PriceOption({ data }: { data: PriceOptionProps }): JSX.Element {
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(
      data.period === 'lifetime'
        ? data.insidersRedirectLink
        : data.premiumRedirectLink
    )
  }, [data.insidersRedirectLink, data.period, data.premiumRedirectLink])

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
        <ModalHeader period={data.period} />
        <hr className="mb-32 border-borderColor5 -mx-48" />
        <ExercismStripeElements>
          <StripeForm
            {...data}
            amount={currency(data.displayAmount)}
            onSuccess={handleSuccess}
          />
        </ExercismStripeElements>
        <ModalFooter period={data.period} />
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

export function ModalHeader({ period }: { period: Period }): JSX.Element {
  if (period == 'lifetime') {
    return (
      <>
        <div className="flex flex-row items-center gap-8 mb-16">
          <GraphicalIcon icon="premium" className="w-[48px] h-[48px]" />
          <div className="text-h2">+</div>
          <GraphicalIcon icon="insiders" className="w-[48px] h-[48px]" />
        </div>
        <h2 className="text-h2 mb-2 !text-white">
          Exercism Premium + Insiders
        </h2>
        <p className="text-p-large mb-20 !text-white">
          Thank you so much for supporting Exercism and our backing our vision
          for equal education in society. We hope you love our Premium features
          and Insiders behind-the-scenes access!
        </p>
      </>
    )
  }
  return (
    <>
      <GraphicalIcon icon="premium" className="w-[48px] h-[48px] mb-16" />
      <h2 className="text-h2 mb-2 !text-white">Exercism Premium</h2>
      <p className="text-p-large mb-20 !text-white">
        Congratulations on upgrading to Exercism Premium. Please enter your card
        details below to get started.
      </p>
    </>
  )
}

export function ModalFooter({ period }: { period: Period }): JSX.Element {
  if (period == 'lifetime') {
    return (
      <p className="text-p-small mt-20">
        Exercism is a registered not-for-profit organization based in the United
        Kingdom (#11733062).
      </p>
    )
  }

  return (
    <p className="text-p-small mt-20">
      All payments are handled securely via Stripe. You can cancel your
      subscription through Settings at any time.
    </p>
  )
}
