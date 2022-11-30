import React, { useState, useCallback } from 'react'
import { Form } from './Form'
import { PaymentIntentType } from './StripeForm'
import SuccessModal from './SuccessModal'
import currency from 'currency.js'
import { Request } from '../../hooks/request-query'

type Links = {
  donate: string
  settings: string
}

type FormWithModalProps = {
  request: Request
  userSignedIn: boolean
  links: Links
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
