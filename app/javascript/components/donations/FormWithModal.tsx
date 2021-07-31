import React, { useState, useCallback } from 'react'
import { Form } from './Form'
import { PaymentIntentType } from './StripeForm'
import { Modal } from '../modals/Modal'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { BadgeMedallion } from '../common/BadgeMedallion'

type Links = {
  donate: string
  settings: string
}

export default ({
  existingSubscriptionAmountinDollars,
  links,
}: {
  existingSubscriptionAmountinDollars: number | null
  links: Links
}) => {
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

  /*TODO: Decide on correct icon */
  const badge = { rarity: 'rare', iconName: 'automation' }
  return (
    <>
      <Form
        onSuccess={handleSuccess}
        existingSubscriptionAmountinDollars={
          existingSubscriptionAmountinDollars
        }
        links={links}
      />
      <Modal
        open={paymentMade}
        onClose={() => {}}
        className="m-donation-confirmation"
      >
        <GraphicalIcon icon="completed-check-circle" className="main-icon" />
        <h2 className="text-h3 mb-8">
          You’ve donated ${paymentAmountInDollars} successfully - thank you 💙
        </h2>
        <p className="text-p-large mb-24">
          We truly appreciate your support. Exercism would not be possible
          without awesome contributors like yourself. You’ll be sent an email
          shortly with your donation confirmation and receipt.
        </p>
        <div className="flex items-center rounded-5 shadow-xsZ1 py-6 px-24 bg-lightOrange mb-32 border-1 border-lightGold">
          {/* TODO: Make this works: <BadgeMedallion badge={badge} />*/}
          <div className="text-textColor2 text-18 leading-150">
            You’ve earned the{' '}
            <strong className="font-medium"> Supporter</strong> badge!
          </div>
        </div>

        <a href={links.donate} className="btn-primary btn-l w-100">
          Happy to help! I&apos;m done here 👍
        </a>
      </Modal>
    </>
  )
}
