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

export default ({
  request,
  userSignedIn,
  links,
}: {
  request: Request
  userSignedIn: boolean
  links: Links
}) => {
  const [paymentMade, setPaymentMade] = useState(false)
  const [paymentType, setPaymentType] = useState<
    PaymentIntentType | undefined
  >()
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
      />
      <SuccessModal
        open={paymentMade}
        amount={paymentAmount}
        closeLink={links.donate}
      />
    </>
  )
}
