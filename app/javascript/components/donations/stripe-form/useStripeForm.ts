import { fetchJSON } from '@/utils/fetch-json'
import { useStripe, useElements, CardElement } from '@stripe/react-stripe-js'
import {
  StripePaymentElementChangeEvent,
  StripeCardElementChangeEvent,
  StripeCardElement,
  Stripe,
  StripeError,
  StripeElements,
} from '@stripe/stripe-js'
import { useState, useCallback, useEffect } from 'react'
import { StripeFormProps } from '../StripeForm'

type UseStripeFormParams = Pick<
  StripeFormProps,
  | 'captchaRequired'
  | 'paymentIntentType'
  | 'amount'
  | 'onProcessing'
  | 'onSettled'
  | 'onSuccess'
  | 'confirmParamsReturnUrl'
>

type PaymentIntent = {
  id: string
  clientSecret: string
}
export type PaymentIntentType = 'payment' | 'subscription'

type UseStripeFormReturns = {
  succeeded: boolean
  error: string | undefined
  cardValid: boolean
  notARobot: boolean
  email: string
  processing: boolean
  handlePaymentElementChange: (
    event: StripePaymentElementChangeEvent
  ) => Promise<void>
  handleCardChange: (event: StripeCardElementChangeEvent) => Promise<void>
  handleCardReady: (element: StripeCardElement) => Promise<void>
  handleEmailChange: React.ChangeEventHandler<HTMLInputElement>
  handleCaptchaSuccess: () => void
  handleCaptchaFailure: () => void
  handleSubmit: (event: React.ChangeEvent<HTMLFormElement>) => Promise<void>
  handlePaymentSubmit: (
    event: React.ChangeEvent<HTMLFormElement>
  ) => Promise<void>
}

export function useStripeForm({
  captchaRequired,
  paymentIntentType,
  amount,
  confirmParamsReturnUrl,
  onSuccess,
  onProcessing = () => null,
  onSettled = () => null,
}: UseStripeFormParams): UseStripeFormReturns {
  const [succeeded, setSucceeded] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const [processing, setProcessing] = useState(false)
  const [cardValid, setCardValid] = useState(false)
  const [notARobot, setNotARobot] = useState(!captchaRequired)
  const [email, setEmail] = useState('')

  const createPaymentIntentEndpoint = '/api/v2/payments/payment_intents'
  const paymentIntentFailedEndpoint =
    '/api/v2/payments/payment_intents/$ID/failed'
  const paymentIntentSucceededEndpoint =
    '/api/v2/payments/payment_intents/$ID/succeeded'

  const stripe = useStripe()
  const elements = useElements()

  const handlePaymentElementChange = async (
    event: StripePaymentElementChangeEvent
  ) => {
    // When we've got a completed card with no errors, set the card to be valid
    setCardValid(event.complete)
  }

  const handleCardChange = async (event: StripeCardElementChangeEvent) => {
    // When we've got a completed card with no errors, set the card to be valid
    setCardValid(event.complete)
  }

  // Focus on the card number once the element loads
  const handleCardReady = async (element: StripeCardElement) => {
    element.focus()
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

  const notifyServerOfSuccess = useCallback(
    async (paymentIntent: PaymentIntent) => {
      const endpoint = paymentIntentSucceededEndpoint.replace(
        '$ID',
        paymentIntent.id
      )
      return fetchJSON(endpoint, {
        method: 'PATCH',
      })
    },
    []
  )

  type PaymentRequestReturnData = {
    paymentIntent: PaymentIntent
    error: string
  }
  const getPaymentRequest = useCallback(async () => {
    return fetchJSON<PaymentRequestReturnData>(createPaymentIntentEndpoint, {
      method: 'POST',
      body: JSON.stringify({
        type: paymentIntentType,
        amount_in_cents: amount.intValue,
        email,
      }),
    }).then((data) => {
      if (data.error) {
        setError(`Payment failed with error: ${data.error}`)
        return null
      }
      return data.paymentIntent
    })
  }, [paymentIntentType, amount.intValue, email])

  type ConfirmPaymentFn = (
    stripe: Stripe,
    elements: StripeElements,
    paymentIntent: PaymentIntent
  ) => Promise<{ error?: StripeError }>

  const handlePayment = async (
    event: React.ChangeEvent<HTMLFormElement>,
    confirmPaymentFn: ConfirmPaymentFn
  ) => {
    event.preventDefault()

    if (!stripe || !elements) {
      return
    }

    setProcessing(true)
    setError(undefined)

    const { error: submitError } = await elements.submit()
    if (submitError) {
      setError(submitError ? submitError.message : undefined)
      return
    }

    getPaymentRequest().then(async (paymentIntent: PaymentIntent | null) => {
      if (paymentIntent === undefined || paymentIntent === null) {
        setProcessing(false)
        return
      }

      const { error } = await confirmPaymentFn(stripe, elements, paymentIntent)

      if (error) {
        setError(
          `Your payment failed. The message we got back from your bank was "${error.message}"`
        )
        setProcessing(false)
        cancelPaymentIntent(paymentIntent)
      } else {
        setError(undefined)
        setProcessing(false)
        setSucceeded(true)
        await notifyServerOfSuccess(paymentIntent)
        onSuccess(paymentIntentType, amount)
      }
    })
  }

  const handleSubmit = (event: React.ChangeEvent<HTMLFormElement>) =>
    handlePayment(
      event,
      async (
        stripe: Stripe,
        elements: StripeElements,
        paymentIntent: PaymentIntent
      ) => {
        const cardElement = elements.getElement(CardElement)
        if (!cardElement)
          return {
            error: {
              message: 'Card element not found',
              type: 'validation_error',
            },
          }

        const payload = await stripe.confirmCardPayment(
          paymentIntent.clientSecret,
          {
            payment_method: {
              card: cardElement,
            },
          }
        )

        return { payload, error: payload.error }
      }
    )

  const handlePaymentSubmit = (event: React.ChangeEvent<HTMLFormElement>) =>
    handlePayment(
      event,
      (
        stripe: Stripe,
        elements: StripeElements,
        paymentIntent: PaymentIntent
      ) =>
        stripe.confirmPayment({
          elements,
          clientSecret: paymentIntent.clientSecret,
          confirmParams: {
            return_url: confirmParamsReturnUrl,
          },
          redirect: 'if_required',
        })
    )

  useEffect(() => {
    processing ? onProcessing() : onSettled()
  }, [onProcessing, onSettled, processing])

  const handleEmailChange = useCallback((e) => {
    setEmail(e.target.value)
  }, [])

  const handleCaptchaSuccess = useCallback(() => {
    setNotARobot(true)
  }, [])

  const handleCaptchaFailure = useCallback(() => {
    setNotARobot(false)
  }, [])

  return {
    handleSubmit,
    handlePaymentSubmit,
    cardValid,
    error,
    handleCaptchaFailure,
    handleCaptchaSuccess,
    handleCardChange,
    handleCardReady,
    handleEmailChange,
    handlePaymentElementChange,
    notARobot,
    succeeded,
    email,
    processing,
  }
}
