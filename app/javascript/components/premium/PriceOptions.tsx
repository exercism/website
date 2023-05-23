import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { Modal } from '../modals'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { PaymentIntentType, StripeForm } from '../donations/StripeForm'
import PremiumSubscriptionSuccessModal from '../donations/PremiumSubscriptionSuccessModal'

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
  paypalLink: string
}

type PriceCardProps = PriceOption & { onStripeClick: () => void }

const PRICE_OPTIONS: PriceOption[] = [
  {
    period: 'month',
    displayAmount: 9.99,
    paymentIntentType: 'premium_monthly_subscription',
    paypalLink:
      'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-23J11871PJ838224HMRTXYTA',
  },
  {
    period: 'year',
    displayAmount: 99.99,
    paymentIntentType: 'premium_yearly_subscription',
    paypalLink:
      'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-23J11871PJ838224HMRTXYTA',
    favorite: true,
  },
  {
    period: 'lifetime',
    displayAmount: 500,
    paymentIntentType: 'premium_lifetime_subscription',
    paypalLink:
      'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-79144942EH3169155MRTX2NI',
  },
]
export function PriceOptions({ data }: Props): JSX.Element {
  const [stripeModalOpen, setStripeModalOpen] = useState(false)
  const [selectedOption, setSelectedOption] = useState(PRICE_OPTIONS[0])
  const [paymentMade, setPaymentMade] = useState(false)

  // TODO: Remove this as this seems to be unused
  const [, setPaymentType] = useState<PaymentIntentType | undefined>()
  const [paymentAmount, setPaymentAmount] = useState<currency | null>(null)

  const handleSuccess = useCallback(
    (type: PaymentIntentType, amount: currency) => {
      setPaymentType(type)
      setPaymentAmount(amount)
      setPaymentMade(true)
      setStripeModalOpen(false)
    },
    []
  )

  const handleModalOpen = useCallback((option) => {
    setSelectedOption(option)
    setStripeModalOpen(true)
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
      <PremiumSubscriptionSuccessModal
        open={paymentMade}
        closeLink="/donate"
        amount={paymentAmount}
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
            paymentIntentType={selectedOption.paymentIntentType}
            amount={currency(selectedOption.displayAmount)}
            onSuccess={handleSuccess}
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
  paypalLink,
}: PriceCardProps): JSX.Element {
  return (
    <div
      className={`price-card ${favorite && 'border-gradient-russianViolet'}`}
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
      <a href={paypalLink} className="btn-m btn-primary">
        <GraphicalIcon
          icon="paypal"
          category="graphics"
          className="!filter-none"
        />
        <span>Subscribe via PayPal</span>
      </a>
    </div>
  )
}
