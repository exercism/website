import React, { useState, useCallback } from 'react'
import currency from 'currency.js'
import { Request } from '@/hooks'
import { Form } from './Form'
import SuccessModal from './SuccessModal'
import { PaymentIntentType } from './stripe-form/useStripeForm'

export type FormWithModalLinks = {
  donate: string
  settings: string
}

type FormWithModalProps = {
  request: Request
  userSignedIn: boolean
  links: FormWithModalLinks
  captchaRequired: boolean
  recaptchaSiteKey: string
}

export default function FormWithModal({
  request,
  userSignedIn,
  links,
  captchaRequired,
  recaptchaSiteKey,
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
      />
      <SuccessModal
        open={paymentMade}
        amount={paymentAmount}
        closeLink={links.donate}
      />
    </>
  )
}
