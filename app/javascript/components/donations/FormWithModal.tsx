import React, { useState, useCallback } from 'react'
import { Form } from './Form'
import { PaymentIntentType } from './StripeForm'
import { Modal } from '../modals/Modal'

export default () => {
  const [paymentMade, setPaymentMade] = useState(false)
  const [paymentType, setPaymentType] = useState<
    PaymentIntentType | undefined
  >()
  const [paymentAmountInDollars, setPaymentAmountInDollars] = useState<
    number | undefined
  >()

  const handleSuccess = useCallback(
    (type: PaymentIntentType, amountInDollars: number) => {
      setPaymentType(type)
      setPaymentAmountInDollars(amountInDollars)
      setPaymentMade(true)
    },
    []
  )

  return (
    <>
      <Form onSuccess={handleSuccess} />
      <Modal
        open={paymentMade}
        onClose={() => {}}
        className="m-donation-confirmation"
      >
        Thank you for your payment of ${paymentAmountInDollars}.
      </Modal>
    </>
  )
}
