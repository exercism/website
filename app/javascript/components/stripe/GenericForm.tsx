import React, { useCallback, useState } from 'react'
import { Icon } from '../common'
import { sendRequest } from '../../utils/send-request'
import { StripeCardElementChangeEvent } from '@stripe/stripe-js'
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js'
import { fetchJSON } from '../../utils/fetch-json'

type PaymentIntent = {
  id: string
  clientSecret: string
}
export type PaymentIntentType = 'payment' | 'subscription'

export function GenericForm({
  paymentIntentType,
  amountInDollars,
  onSuccess,
}: {
  paymentIntentType: PaymentIntentType
  onSuccess: () => void
  amountInDollars: number
}) {
  const [succeeded, setSucceeded] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [processing, setProcessing] = useState(false)
  const [cardValid, setCardValid] = useState(false)

  const createPaymentIntentEndpoint = '/api/v2/donations/payment_intents'
  const cancelPaymentIntentEndpoint =
    '/api/v2/donations/payment_intents/$ID/failed'

  const cardStyle = {
    base: {
      color: '#32325d',
      fontFamily: 'Arial, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#32325d',
      },
    },
    invalid: {
      fontFamily: 'Arial, sans-serif',
      color: '#fa755a',
      iconColor: '#fa755a',
    },
  }
  const cardOptions = { style: cardStyle }

  const stripe = useStripe()
  const elements = useElements()

  const handleCardChange = async (event: StripeCardElementChangeEvent) => {
    // When we've got a completed card with no errors, set the card to be valid
    setCardValid(event.complete && !event.error)

    // If there are errors, display them.
    setError(event.error ? event.error.message : undefined)
  }

  // TODO: Do I need to usecallback here, or just normal function?
  const cancelPaymentIntent = useCallback((paymentIntent: PaymentIntent) => {
    const endpoint = cancelPaymentIntentEndpoint.replace(
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
        amount_in_dollars: amountInDollars,
      }),
    }).then((data: any) => data.paymentIntent)
  }, [paymentIntentType, amountInDollars])

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
        setError(`Payment failed ${payload.error.message}`)
        setProcessing(false)
        cancelPaymentIntent(paymentIntent)
      } else {
        setError(undefined)
        setProcessing(false)
        setSucceeded(true)
        onSuccess()
      }
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="card-element">
        <CardElement options={cardOptions} onChange={handleCardChange} />
      </div>
      <button type="submit">Do it!!</button>
      <button
        className="btn-primary btn-s"
        type="submit"
        disabled={processing || !cardValid || succeeded}
      >
        {processing ? <Icon icon="spinner" alt="Progressing" /> : null}
        <span>Donate to Exercism</span>
      </button>
      {error && (
        <div className="card-error" role="alert">
          {error}
        </div>
      )}
      {succeeded ? <p className="result-message">Payment succeeded!</p> : null}
    </form>
  )
}
