import React, { useCallback, useState, useEffect } from 'react'
import ReCAPTCHA from 'react-google-recaptcha'
import currency from 'currency.js'
import { StripeCardElementChangeEvent } from '@stripe/stripe-js'
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js'
import { Icon } from '@/components/common'
import { fetchJSON } from '@/utils/fetch-json'

const cardOptions = {
  style: {
    base: {
      backgroundColor: 'transparent',
      color: 'grey',
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
export type PaymentIntentType =
  | 'payment'
  | 'subscription'
  | 'premium_yearly_subscription'
  | 'premium_monthly_subscription'
  | 'premium_lifetime_subscription'

type StripeFormProps = {
  paymentIntentType: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  onProcessing?: () => void
  onSettled?: () => void
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
  amount: currency
}

export function StripeForm({
  paymentIntentType,
  amount,
  onSuccess,
  onProcessing = () => null,
  userSignedIn,
  recaptchaSiteKey,
  captchaRequired,
  onSettled = () => null,
}: StripeFormProps): JSX.Element {
  const [succeeded, setSucceeded] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [processing, setProcessing] = useState(false)
  const [cardValid, setCardValid] = useState(false)
  const [notARobot, setNotARobot] = useState(!captchaRequired)
  // this can be passed to the backend
  const [captchaToken, setCaptchaToken] = useState('')
  const [email, setEmail] = useState('')

  const createPaymentIntentEndpoint = '/api/v2/payments/payment_intents'
  const paymentIntentFailedEndpoint =
    '/api/v2/payments/payment_intents/$ID/failed'
  const paymentIntentSucceededEndpoint =
    '/api/v2/payments/payment_intents/$ID/succeeded'

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
        email: email,
      }),
    }).then((data: any) => {
      if (data.error) {
        setError(`Payment failed with error: ${data.error}`)
        return null
      }
      return data.paymentIntent
    })
  }, [paymentIntentType, amount.intValue, email])

  const handleSubmit = async (event: React.ChangeEvent<HTMLFormElement>) => {
    event.preventDefault()

    if (!stripe || !elements) {
      // Stripe.js has not loaded yet. Make sure to disable
      // form submission until Stripe.js has loaded.
      return
    }

    // Set as processing to disable the button
    setProcessing(true)
    setError(undefined)

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

  useEffect(() => {
    processing ? onProcessing() : onSettled()
  }, [onProcessing, onSettled, processing])

  const handleEmailChange = useCallback((e) => {
    setEmail(e.target.value)
  }, [])

  const handleCaptchaSuccess = useCallback((token) => {
    setNotARobot(true)
    setCaptchaToken(token)
  }, [])

  const handleCaptchaFailure = useCallback(() => {
    setNotARobot(false)
    setCaptchaToken('')
  }, [])

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      {!userSignedIn ? (
        <div className="email-container">
          <label htmlFor="email">Your email address (for receipts):</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={handleEmailChange}
          />
        </div>
      ) : null}
      {captchaRequired ? (
        <div className="flex items-center mb-16">
          <ReCAPTCHA
            sitekey={recaptchaSiteKey}
            className="g-recaptcha"
            onChange={handleCaptchaSuccess}
            onExpired={handleCaptchaFailure}
            onErrored={handleCaptchaFailure}
          />
          <div className="ml-16 text-textColor6 leading-tight">
            Due to frequent{' '}
            <a
              href="https://stripe.com/docs/disputes/prevention/card-testing"
              target="_blank"
              rel="noreferrer"
              className="underline"
            >
              card testing attacks
            </a>
            , we need to check you are not a bot before we can accept a
            donation.
          </div>
        </div>
      ) : null}
      <div className="card-container">
        <div className="title">
          {paymentIntentType.startsWith('premium') ? 'Subscribe' : 'Donate'}{' '}
          with Card
        </div>
        <div className="card-element">
          <CardElement options={cardOptions} onChange={handleCardChange} />
          <button
            className="btn-primary btn-s"
            type="submit"
            disabled={
              !notARobot ||
              processing ||
              !cardValid ||
              succeeded ||
              (!userSignedIn && email.length === 0)
            }
          >
            {processing ? <Icon icon="spinner" alt="Progressing" /> : null}
            <span>{generateStripeButtonText(paymentIntentType, amount)}</span>
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

function generateStripeButtonText(
  paymentIntent: PaymentIntentType,
  amount: currency
) {
  switch (paymentIntent) {
    case 'payment':
      return `Donate ${amount.format()} to Exercism`
    case 'subscription':
      return `Donate ${amount.format()} to Exercism monthly`
    case 'premium_lifetime_subscription':
      return `Subscribe for Premium for lifetime for ${amount.format()}`
    case 'premium_monthly_subscription':
      return `Subscribe for Premium for ${amount.format()}/month`
    case 'premium_yearly_subscription':
      return `Subscribe for Premium for ${amount.format()}/year`
  }
}
