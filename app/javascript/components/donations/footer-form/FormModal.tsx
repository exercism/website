import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import currency from 'currency.js'
import SuccessModal from '../SuccessModal'
import { Form } from '../Form'
import { Request } from '../../../hooks/request-query'

type ModalStep = 'donating' | 'processingDonation' | 'donationSuccess'

type Links = {
  settings: string
}

export const FormModal = ({
  amount,
  onClose,
  request,
  links,
  userSignedIn,
  ...props
}: Omit<ModalProps, 'className'> & {
  amount: currency
  request: Request
  links: Links
  userSignedIn: boolean
}): JSX.Element => {
  const [step, setStep] = useState<ModalStep>('donating')
  const [paidAmount, setPaidAmount] = useState<currency | null>(null)

  const handleClose = useCallback(() => {
    if (step === 'processingDonation') {
      return
    }

    if (step === 'donationSuccess') {
      setStep('donating')
    }

    onClose()
  }, [onClose, step])

  const handleDonationSuccess = useCallback((actualType, actualAmount) => {
    setPaidAmount(actualAmount)
    setStep('donationSuccess')
  }, [])

  const handleDonationProcessing = useCallback(() => {
    setStep('processingDonation')
  }, [])

  const handleDonationSettled = useCallback(() => {
    setStep('donating')
  }, [])

  switch (step) {
    case 'donating':
    case 'processingDonation':
      return (
        <Modal
          closeButton={true}
          className="m-donations-form"
          onClose={handleClose}
          {...props}
        >
          <Form
            request={request}
            defaultAmount={{ payment: amount, subscription: amount }}
            defaultTransactionType="payment"
            onSuccess={handleDonationSuccess}
            links={links}
            onProcessing={handleDonationProcessing}
            onSettled={handleDonationSettled}
            userSignedIn={userSignedIn}
          />
        </Modal>
      )

    case 'donationSuccess':
      /* Kntsoriano - the amount here needs to be updated in the success callback */
      return (
        <SuccessModal
          open={true}
          amount={paidAmount}
          closeLink={window.location.href}
        />
      )
  }
}
