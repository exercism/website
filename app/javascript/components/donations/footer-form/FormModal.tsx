import React, { useState, useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import currency from 'currency.js'
import { DonationSuccess } from './stripe-form-modal/DonationSuccess'
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
  ...props
}: Omit<ModalProps, 'className'> & {
  amount: currency
  request: Request
  links: Links
}): JSX.Element => {
  const [step, setStep] = useState<ModalStep>('donating')

  const handleClose = useCallback(() => {
    if (step === 'processingDonation') {
      return
    }

    if (step === 'donationSuccess') {
      setStep('donating')
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
        <Form
          request={request}
          defaultAmount={{ payment: amount, subscription: amount }}
          defaultTransactionType="payment"
          onSuccess={handleDonationSuccess}
          links={links}
          onProcessing={handleDonationProcessing}
          onSettled={handleDonationSettled}
        />
      )

      break
    case 'donationSuccess':
      content = <DonationSuccess />
  }

  return (
    <Modal className="m-donations-form" onClose={handleClose} {...props}>
      {content}
    </Modal>
  )
}
