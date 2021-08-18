import React, { useCallback, useState } from 'react'
import { Icon } from '../common'
import { loadStripe, StripeCardElementChangeEvent } from '@stripe/stripe-js'
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js'
import { fetchJSON } from '../../utils/fetch-json'
import currency from 'currency.js'

const cardOptions = {
  style: {
    base: {
      backgroundColor: '#ffffff',
      color: '#130B43',
      fontFamily: 'Poppins, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      lineHeight: '32px',
      fontWeight: '500',
      '::placeholder': {
        color: '#76709F',
      },
    },
    invalid: {
      color: '#D03B3B',
      iconColor: '#D03B3B',
    },
  },
}

type PaymentIntent = {
  id: string
  clientSecret: string
}
export type PaymentIntentType = 'payment' | 'subscription'

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(
  'pk_test_51IDGMXEoOT0Jqx0UcoKlkvB7O0VDvFdCBvOCiWiKv6CkSnkZn7IG6cIHuCWg7cegGogYJSy8WsaKzwFHQqN75T7b00d56MtilB'
)

export function StripeForm({
  paymentIntentType,
  amount,
  onSuccess,
}: {
  paymentIntentType: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  amount: currency
}) {
  const [succeeded, setSucceeded] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [processing, setProcessing] = useState(false)
  const [cardValid, setCardValid] = useState(false)

  const createPaymentIntentEndpoint = '/api/v2/donations/payment_intents'
  const paymentIntentFailedEndpoint =
    '/api/v2/donations/payment_intents/$ID/failed'
  const paymentIntentSucceededEndpoint =
    '/api/v2/donations/payment_intents/$ID/succeeded'

  const stripe = useStripe()
  const elements = useElements()

  const handleCardChange = async (event: StripeCardElementChangeEvent) => {
    // When we've got a completed card with no errors, set the card to be valid
    setCardValid(event.complete && !event.error)

    // If there are errors, display them.
    setError(event.error ? event.error.message : undefined)
  }

  const cancelPaymentIntent = useCallback((paymentIntent: PaymentIntent) => {
    const endpoint = paymentIntentFailedEndpoint.replace(
      '$ID',
      paymentIntent.id
    )
    return fetchJSON(endpoint, {
      method: 'PATCH',
    })
  }, [])

  const notifyServerOfSuccess = useCallback((paymentIntent: PaymentIntent) => {
    const endpoint = paymentIntentSucceededEndpoint.replace(
      '$ID',
      paymentIntent.id
    )
    return fetchJSON(endpoint, {
      method: 'PATCH',
    })
  }, [])

  const getPaymentRequest = useCallback(() => {
    return fetchJSON(createPaymentIntentEndpoint, {
      method: 'POST',
      body: JSON.stringify({
        type: paymentIntentType,
        amount_in_cents: amount.intValue,
      }),
    }).then((data: any) => {
      if (data.error) {
        setError(`Payment failed with error: ${data.error}`)
        return null
      }
      return data.paymentIntent
    })
  }, [paymentIntentType, amount])

  const handleSubmit = async (event: React.ChangeEvent<HTMLFormElement>) => {
    event.preventDefault()

    if (!stripe || !elements) {
      // Stripe.js has not loaded yet. Make sure to disable
      // form submission until Stripe.js has loaded.
      return
    }

    // Set as processing to disable the button
    setProcessing(true)

    getPaymentRequest().then(async (paymentIntent: PaymentIntent) => {
      // If we've failed to get a payment intent get out of here
      if (paymentIntent === undefined || paymentIntent === null) {
        setProcessing(false)
        return
      }

      // Get a reference to a mounted CardElement. Elements knows how
      // to find the CardElement because there can only ever be one of
      // each type of element. We could maybe use a ref here instead?
      const cardElement = elements.getElement(CardElement)!
      const payload = await stripe.confirmCardPayment(
        paymentIntent.clientSecret,
        {
          payment_method: {
            card: cardElement,
          },
        }
      )

      if (payload.error) {
        setError(
          `Your payment failed. The message we got back from your bank was "${payload.error.message}"`
        )
        setProcessing(false)
        cancelPaymentIntent(paymentIntent)
      } else {
        setError(undefined)
        setProcessing(false)
        setSucceeded(true)
        notifyServerOfSuccess(paymentIntent)
        onSuccess(paymentIntentType, amount)
      }
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="card-container">
        <div className="title">Donate with Card</div>
        <div className="card-element">
          <CardElement options={cardOptions} onChange={handleCardChange} />
          <button
            className="btn-primary btn-s"
            type="submit"
            /*disabled={processing || !cardValid || succeeded}*/
          >
            {processing ? <Icon icon="spinner" alt="Progressing" /> : null}
            <span>
              {paymentIntentType == 'payment'
                ? `Donate ${amount.format()} to Exercism`
                : `Donate ${amount.format()} to Exercism monthly`}
            </span>
          </button>
        </div>
      </div>
      {error && (
        <div className="card-error" role="alert">
          {error}
        </div>
      )}
      {paymentIntentType == 'subscription' ? (
        <div className="extra-info">
          Thank you for your ongoing support! We will debit {amount.format()} on
          around this day each month. You can change or cancel your donation at
          any time.
        </div>
      ) : null}
    </form>
  )
}
