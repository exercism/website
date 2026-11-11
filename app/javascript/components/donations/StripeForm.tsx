import React from 'react'
import ReCAPTCHA from 'react-google-recaptcha'
import currency from 'currency.js'
import { PaymentElement } from '@stripe/react-stripe-js'
import { Icon } from '@/components/common'
import { PaymentIntentType, useStripeForm } from './stripe-form/useStripeForm'
import { generateStripeButtonText } from './stripe-form/utils'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'
import type { PaymentTrigger } from '@/utils/analytics'

export type StripeFormProps = {
  paymentIntentType: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  onProcessing?: () => void
  onSettled?: () => void
  captchaRequired: boolean
  recaptchaSiteKey?: string
  amount: currency
  submitButtonDisabled?: boolean
  confirmParamsReturnUrl: string
  // Where in the UI this checkout was opened, for analytics.
  trigger?: PaymentTrigger
}

export function StripeForm({
  paymentIntentType,
  amount,
  onSuccess,
  onProcessing = () => null,
  recaptchaSiteKey,
  captchaRequired,
  submitButtonDisabled = false,
  confirmParamsReturnUrl,
  onSettled = () => null,
  trigger,
}: StripeFormProps): JSX.Element {
  const { t } = useAppTranslation('components/donations')
  const {
    cardValid,
    error,
    processing,
    notARobot,
    succeeded,
    handleCaptchaFailure,
    handleCaptchaSuccess,
    handlePaymentElementChange,
    handlePaymentSubmit,
  } = useStripeForm({
    captchaRequired,
    amount,
    confirmParamsReturnUrl,
    onSuccess,
    paymentIntentType,
    onProcessing,
    onSettled,
    trigger,
  })

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
      {captchaRequired && recaptchaSiteKey ? (
        <div className="flex items-center mb-16">
          <ReCAPTCHA
            sitekey={recaptchaSiteKey}
            className="g-recaptcha"
            onChange={handleCaptchaSuccess}
            onExpired={handleCaptchaFailure}
            onErrored={handleCaptchaFailure}
          />
          <div className="ms-16 text-textColor6 leading-tight">
            <Trans
              ns="components/donations"
              i18nKey="stripeForm.attackInfo"
              components={[
                <a
                  href="https://stripe.com/docs/disputes/prevention/card-testing"
                  target="_blank"
                  rel="noreferrer"
                  className="underline"
                />,
              ]}
            />
          </div>
        </div>
      ) : null}

      <PaymentElement
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        options={paymentElementOptions}
        onChange={handlePaymentElementChange}
      />
      <button
        className="btn-primary btn-m mt-16"
        type="submit"
        disabled={
          !notARobot ||
          processing ||
          !cardValid ||
          succeeded ||
          submitButtonDisabled
        }
      >
        {processing ? (
          <Icon
            icon="spinner"
            alt={t('stripeForm.progressing')}
            className="animate-spin"
          />
        ) : null}
        <span>{generateStripeButtonText(paymentIntentType, amount)}</span>
      </button>

      {error && (
        <div className="c-donation-card-error" role="alert">
          {error}
        </div>
      )}
    </form>
  )
}
