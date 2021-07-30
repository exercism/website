import React, { useCallback, useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { StripeForm, PaymentIntentType } from './StripeForm'
import { SubscriptionForm } from './SubscriptionForm'
import { PaymentForm } from './PaymentForm'

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(
  'pk_test_51IDGMXEoOT0Jqx0UcoKlkvB7O0VDvFdCBvOCiWiKv6CkSnkZn7IG6cIHuCWg7cegGogYJSy8WsaKzwFHQqN75T7b00d56MtilB'
)

const elementsOptions = {
  fonts: [
    {
      cssSrc:
        'https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap',
    },
  ],
}

export function Form({
  existingSubscriptionAmountinDollars,
  onSuccess,
}: {
  existingSubscriptionAmountinDollars: number | null
  onSuccess: (type: PaymentIntentType, amountInDollars: number) => void
}) {
  const [amountInDollars, setAmountInDollars] = useState(32)
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    'subscription'
  )

  const handleAmountChange = useCallback((e) => {
    if (e.target.value == 0) {
      return
    }

    setAmountInDollars(e.target.value)

    for (let descendant of e.target.closest('.amounts').querySelectorAll('*')) {
      descendant.classList.remove('selected')
    }
    e.target.closest('.c-faux-input, button').classList.add('selected')
  }, [])

  return (
    <div className="c-donations-form">
      <div className="--tabs">
        <button
          className="tab selected"
          onClick={() => setTransactionType('subscription')}
        >
          💙 Monthly
        </button>
        <button className="tab" onClick={() => setTransactionType('payment')}>
          One-off
        </button>
      </div>
      <div className="--content">
        <SubscriptionForm
          existingSubscriptionAmountinDollars={
            existingSubscriptionAmountinDollars
          }
          handleAmountChange={handleAmountChange}
          visible={transactionType == 'subscription'}
        />
        <PaymentForm
          handleAmountChange={handleAmountChange}
          visible={transactionType == 'payment'}
        />

        <Elements stripe={stripePromise} options={elementsOptions}>
          <StripeForm
            paymentIntentType={transactionType}
            amountInDollars={amountInDollars}
            onSuccess={onSuccess}
          />
        </Elements>
      </div>
    </div>
  )
}
