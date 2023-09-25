import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import currency from 'currency.js'
import SuccessModal from '../SuccessModal'
import { Form, StripeFormLinks } from '../Form'
import { Request } from '../../../hooks/request-query'

type ModalStep = 'donating' | 'processingDonation' | 'donationSuccess'

type Props = {
  amount: currency
  request: Request
  links: StripeFormLinks
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
}

export const FormModal = ({
  amount,
  onClose,
  request,
  links,
  userSignedIn,
  captchaRequired,
  recaptchaSiteKey,
  ...props
}: Omit<ModalProps, 'className'> & Props): JSX.Element => {
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
          aria={{ describedby: 'a11y-donations-footer-form-modal-description' }}
          className="m-donations-form"
          onClose={handleClose}
          {...props}
        >
          <Form
            id="a11y-donations-footer-form-modal-description"
            request={request}
            defaultAmount={{ payment: amount, subscription: amount }}
            defaultTransactionType="payment"
            onSuccess={handleDonationSuccess}
            links={links}
            onProcessing={handleDonationProcessing}
            onSettled={handleDonationSettled}
            userSignedIn={userSignedIn}
            captchaRequired={captchaRequired}
            recaptchaSiteKey={recaptchaSiteKey}
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
