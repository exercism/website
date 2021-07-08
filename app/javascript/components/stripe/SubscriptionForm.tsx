import React, { useCallback, useState } from 'react'
import { Icon } from '../common'
import { sendRequest } from '../../utils/send-request'
import { StripeCardElementChangeEvent } from '@stripe/stripe-js'
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js'

export function SubscriptionForm({}: {}) {
  const [amountInDollars, setAmountInDollars] = useState(10)
  const [succeeded, setSucceeded] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [processing, setProcessing] = useState(false)
  const [cardValid, setCardValid] = useState(false)

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

  const stripe = useStripe()
  const elements = useElements()

  const handleAmountChange = useCallback((e) => {
    setAmountInDollars(e.target.value)
  }, [])

  const handleCardChange = async (event: StripeCardElementChangeEvent) => {
    // When we've got a completed card with no errors, set the card to be valid
    setCardValid(event.complete && !event.error)

    // If there are errors, display them.
    setError(event.error ? event.error.message : undefined)
  }

  const getPaymentRequest = () => {
    return window
      .fetch('/api/v2/donations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ amount_in_dollars: amountInDollars }),
      })
      .then((res) => res.json())
      .then((data) => data.client_secret)
  }

  const handleSubmit = async (event: React.ChangeEvent<HTMLFormElement>) => {
    // Block native form submission.
    event.preventDefault()

    if (!stripe || !elements) {
      // Stripe.js has not loaded yet. Make sure to disable
      // form submission until Stripe.js has loaded.
      return
    }

    // Set as processing to disable the button
    setProcessing(true)

    getPaymentRequest().then(async (clientSecret: string) => {
      // Get a reference to a mounted CardElement. Elements knows how
      // to find the CardElement because there can only ever be one of
      // each type of element. We could maybe use a ref here instead?
      const cardElement = elements.getElement(CardElement)!
      const payload = await stripe.confirmCardPayment(clientSecret, {
        payment_method: {
          card: cardElement,
        },
      })

      if (payload.error) {
        setError(`Payment failed ${payload.error.message}`)
        setProcessing(false)
      } else {
        setError(undefined)
        setProcessing(false)
        setSucceeded(true)
      }
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      $
      <input
        type="number"
        min="0"
        step="1"
        placeholder="100"
        value={amountInDollars}
        onChange={handleAmountChange}
      />
      <div className="card-element">
        <CardElement
          options={{ style: cardStyle }}
          onChange={handleCardChange}
        />
      </div>
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
