import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import currency from 'currency.js'
import { DonationForm } from './stripe-form-modal/DonationForm'
import { DonationSuccess } from './stripe-form-modal/DonationSuccess'

type ModalStep = 'donating' | 'processingDonation' | 'donationSuccess'

export const StripeFormModal = ({
  amount,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  amount: currency
}): JSX.Element => {
  const [step, setStep] = useState<ModalStep>('donating')

  const handleClose = useCallback(() => {
    if (step === 'processingDonation') {
      return
    }

    onClose()
  }, [onClose, step])

  const handleDonationSuccess = useCallback(() => {
    setStep('donationSuccess')
  }, [])

  const handleDonationProcessing = useCallback(() => {
    setStep('processingDonation')
  }, [])

  const handleDonationSettled = useCallback(() => {
    setStep('donating')
  }, [])

  let content
  switch (step) {
    case 'donating':
    case 'processingDonation':
      content = (
        <DonationForm
          amount={amount}
          onCancel={handleClose}
          onSuccess={handleDonationSuccess}
          onProcessing={handleDonationProcessing}
          onSettled={handleDonationSettled}
        />
      )

      break
    case 'donationSuccess':
      content = <DonationSuccess />
  }

  return (
    <Modal className="m-stripe-form" onClose={handleClose} {...props}>
      {content}
    </Modal>
  )
}
