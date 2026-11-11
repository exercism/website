import React, { useState, useCallback } from 'react'
import currency from 'currency.js'
import { Request } from '@/hooks/request-query'
import { Form, FormAmount, StripeFormLinks } from './Form'
import SuccessModal from './SuccessModal'
import { PaymentIntentType } from './stripe-form/useStripeForm'
import { useTrackPaymentPrompt } from '@/hooks/use-track-payment-prompt'

type FormWithModalProps = {
  request: Request
  links: StripeFormLinks
  captchaRequired: boolean
  recaptchaSiteKey: string
  defaultAmount?: Partial<FormAmount>
}

export default function FormWithModal({
  request,
  links,
  captchaRequired,
  recaptchaSiteKey,
  defaultAmount,
}: FormWithModalProps): JSX.Element {
  const [paymentMade, setPaymentMade] = useState(false)
  useTrackPaymentPrompt('donations_page', userSignedIn)

  // TODO: Remove this as this seems to be unused
  const [, setPaymentType] = useState<PaymentIntentType | undefined>()
  const [paymentAmount, setPaymentAmount] = useState<currency | null>(null)

  const handleSuccess = useCallback(
    (type: PaymentIntentType, amount: currency) => {
      setPaymentType(type)
      setPaymentAmount(amount)
      setPaymentMade(true)
    },
    []
  )

  return (
    <>
      <Form
        onSuccess={handleSuccess}
        request={request}
        links={links}
        recaptchaSiteKey={recaptchaSiteKey}
        captchaRequired={captchaRequired}
        defaultAmount={defaultAmount}
        trigger="donations_page"
      />
      <SuccessModal
        open={paymentMade}
        amount={paymentAmount}
        closeLink={links.success}
      />
    </>
  )
}
