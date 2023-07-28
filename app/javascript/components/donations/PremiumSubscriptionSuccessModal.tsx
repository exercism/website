import React from 'react'
import { Modal } from '../modals/Modal'
import { GraphicalIcon } from '../common/GraphicalIcon'

import currency from 'currency.js'

export default ({
  amount,
  open,
  closeLink,
}: {
  amount: currency | null
  open: boolean
  closeLink: string
}): JSX.Element => {
  return (
    <Modal
      open={open}
      onClose={() => null}
      theme="dark"
      className="m-donation-confirmation"
    >
      <GraphicalIcon icon="completed-check-circle" className="main-icon" />
      <h2 className="text-h3 mb-8">
        You&apos;ve subscribed to Premium successfully - thank you 💙
      </h2>
      <p className="text-p-large mb-24">
        We truly appreciate your support. Exercism would not be possible without
        awesome contributors like yourself. You&apos;ll be sent an email shortly
        with your donation confirmation and receipt.
      </p>
      <div className="badge-container">
        <GraphicalIcon icon="premium" height={20} width={20} className="mr-8" />
        <div className="text-textColor2 text-18 leading-150">
          You&apos;ve earned the{' '}
          <strong className="font-medium"> Premium</strong> flair!
        </div>
      </div>

      <a href={closeLink} className="btn-primary btn-l w-100">
        Happy to help! I&apos;m done here 👍
      </a>
    </Modal>
  )
}
