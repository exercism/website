import React, { useState, useCallback } from 'react'
import currency from 'currency.js'
import { Request } from '@/hooks/request-query'
import { Form, FormAmount, StripeFormLinks } from './Form'
import SuccessModal from './SuccessModal'
import { PaymentIntentType } from './stripe-form/useStripeForm'

type FormWithModalProps = {
  request: Request
  userSignedIn: boolean
  links: StripeFormLinks
  captchaRequired: boolean
  recaptchaSiteKey: string
  defaultAmount?: Partial<FormAmount>
}

export default function FormWithModal({
  request,
  userSignedIn,
  links,
  captchaRequired,
  recaptchaSiteKey,
  defaultAmount,
}: FormWithModalProps): JSX.Element {
  const [paymentMade, setPaymentMade] = useState(false)

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
        userSignedIn={userSignedIn}
        onSuccess={handleSuccess}
        request={request}
        links={links}
        recaptchaSiteKey={recaptchaSiteKey}
        captchaRequired={captchaRequired}
        defaultAmount={defaultAmount}
      />
      <SuccessModal
        open={paymentMade}
        amount={paymentAmount}
        closeLink={links.success}
      />
    </>
  )
}
