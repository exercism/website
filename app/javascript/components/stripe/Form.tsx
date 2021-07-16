import React, { useCallback, useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { GenericForm, PaymentIntentType } from './GenericForm'

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(
  'pk_test_51IDGMXEoOT0Jqx0UcoKlkvB7O0VDvFdCBvOCiWiKv6CkSnkZn7IG6cIHuCWg7cegGogYJSy8WsaKzwFHQqN75T7b00d56MtilB'
)

export function Form({}: {}) {
  const [amountInDollars, setAmountInDollars] = useState(10)
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    'subscription'
  )

  const handleAmountChange = useCallback((e) => {
    setAmountInDollars(e.target.value)
    for (let child of e.target.parentElement.children) {
      child.classList.remove('selected')
    }
    e.target.classList.add('selected')
  }, [])

  return (
    <div className="c-donations-form">
      <div className="tabs">
        <div className="c-tab" onClick={() => setTransactionType('payment')}>
          One-off
        </div>
        <div
          className="c-tab"
          onClick={() => setTransactionType('subscription')}
        >
          Monthly
        </div>
      </div>

      {transactionType == 'payment' ? (
        <div className="amounts">
          <button
            className="btn-default btn-s"
            value={100}
            onClick={handleAmountChange}
          >
            $100
          </button>
          <button
            className="btn-default btn-s"
            value={200}
            onClick={handleAmountChange}
          >
            $200
          </button>
          <button
            className="btn-default btn-s"
            value={500}
            onClick={handleAmountChange}
          >
            $500
          </button>
          $
          <input
            type="number"
            min="0"
            step="1"
            placeholder="Other"
            onChange={handleAmountChange}
          />
        </div>
      ) : (
        <div className="amounts">
          <button
            className="btn-default btn-s"
            value={10}
            onClick={handleAmountChange}
          >
            $10
          </button>
          <button
            className="btn-default btn-s"
            value={20}
            onClick={handleAmountChange}
          >
            $20
          </button>
          <button
            className="btn-default btn-s"
            value={50}
            onClick={handleAmountChange}
          >
            $50
          </button>
          $
          <input
            type="number"
            min="0"
            step="1"
            placeholder="Other"
            onChange={handleAmountChange}
          />
        </div>
      )}

      <Elements stripe={stripePromise}>
        <GenericForm
          paymentIntentType={transactionType}
          amountInDollars={amountInDollars}
          onSuccess={() => null}
        />
      </Elements>
    </div>
  )
}
