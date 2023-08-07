import React from 'react'
import ReCAPTCHA from 'react-google-recaptcha'
import currency from 'currency.js'
import { PaymentElement } from '@stripe/react-stripe-js'
import { Icon } from '@/components/common'
import { PaymentIntentType, useStripeForm } from './stripe-form/useStripeForm'
import {
  generateIntervalText,
  generateStripeButtonText,
} from './stripe-form/utils'
import { generateCardOptions } from './stripe-form/constants'
import { useStripeFormTheme } from './stripe-form/useStripeFormTheme'

export type StripeFormProps = {
  paymentIntentType: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  onProcessing?: () => void
  onSettled?: () => void
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
  amount: currency
  confirmParamsReturnUrl: string
}

export function StripeForm({
  paymentIntentType,
  amount,
  onSuccess,
  onProcessing = () => null,
  userSignedIn,
  recaptchaSiteKey,
  captchaRequired,
  confirmParamsReturnUrl,
  onSettled = () => null,
}: StripeFormProps): JSX.Element {
  const {
    cardValid,
    error,
    email,
    processing,
    notARobot,
    succeeded,
    handleCaptchaFailure,
    handleCaptchaSuccess,
    handleCardChange,
    handleCardReady,
    handleEmailChange,
    handlePaymentElementChange,
    handleSubmit,
    handlePaymentSubmit,
  } = useStripeForm({
    captchaRequired,
    amount,
    confirmParamsReturnUrl,
    onSuccess,
    paymentIntentType,
    onProcessing,
    onSettled,
  })

  const cardOptions = generateCardOptions(useStripeFormTheme())
  const paymentElementOptions = {
    layout: {
      type: 'accordion',
      defaultCollapsed: false,
      radios: true,
      spacedAccordionItems: false,
    },
  }

  return (
    <form data-turbo="false" onSubmit={handlePaymentSubmit}>
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

      <PaymentElement
        options={paymentElementOptions}
        onChange={handlePaymentElementChange}
      />
      <button
        className="btn-primary btn-s mt-16"
        type="submit"
        disabled={
          !notARobot ||
          processing ||
          !cardValid ||
          succeeded ||
          (!userSignedIn && email.length === 0)
        }
      >
        {processing ? (
          <Icon icon="spinner" alt="Progressing" className="animate-spin" />
        ) : null}
        <span>{generateStripeButtonText(paymentIntentType, amount)}</span>
      </button>

      {error && (
        <div className="c-donation-card-error" role="alert">
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
