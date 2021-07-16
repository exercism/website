import React, { useCallback, useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { StripeForm, PaymentIntentType } from './StripeForm'
import { Icon } from '../common'

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

function Amounts({
  transactionType,
  handleAmountChange,
}: {
  transactionType: PaymentIntentType
  handleAmountChange: (e: any) => void
}) {
  return (
    <>
      {transactionType == 'payment' ? (
        <div className="amounts">
          <button
            className="btn-secondary btn-s"
            value={100}
            onClick={handleAmountChange}
          >
            $100
          </button>
          <button
            className="btn-secondary btn-s"
            value={200}
            onClick={handleAmountChange}
          >
            $200
          </button>
          <button
            className="btn-secondary btn-s"
            value={500}
            onClick={handleAmountChange}
          >
            $500
          </button>

          <label className="c-faux-input">
            <div className="icon">$</div>
            <input
              type="number"
              min="0"
              step="1"
              placeholder="Other"
              onChange={handleAmountChange}
            />
          </label>
        </div>
      ) : (
        <div className="amounts">
          <button
            className="btn-secondary btn-s"
            value={10}
            onClick={handleAmountChange}
          >
            $10
          </button>
          <button
            className="btn-secondary btn-s"
            value={20}
            onClick={handleAmountChange}
          >
            $20
          </button>
          <button
            className="btn-secondary btn-s selected"
            value={50}
            onClick={handleAmountChange}
          >
            $50
          </button>

          <label className="c-faux-input">
            <div className="icon">$</div>
            <input
              type="number"
              min="0"
              step="1"
              placeholder="Other"
              onChange={handleAmountChange}
            />
          </label>
        </div>
      )}
    </>
  )
}

export function Form({}: {}) {
  const [amountInDollars, setAmountInDollars] = useState(50)
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    'subscription'
  )

  const handleAmountChange = useCallback((e) => {
    console.log(e)
    setAmountInDollars(e.target.value)
    for (let child of e.target.closest('.amounts').children) {
      child.classList.remove('selected')
    }
    e.target.closest('.c-faux-input, button').classList.add('selected')
  }, [])

  return (
    <div className="c-donations-form">
      <div className="tabs">
        <button className="c-tab" onClick={() => setTransactionType('payment')}>
          One-off
        </button>
        <button
          className="c-tab selected"
          onClick={() => setTransactionType('subscription')}
        >
          💙 Monthly
        </button>
      </div>
      <Amounts
        transactionType={transactionType}
        handleAmountChange={handleAmountChange}
      />

      <Elements stripe={stripePromise} options={elementsOptions}>
        <StripeForm
          paymentIntentType={transactionType}
          amountInDollars={amountInDollars}
          onSuccess={() => null}
        />
      </Elements>
    </div>
  )
}
