import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'
import { FormModal } from './footer-form/FormModal'
import { GraphicalIcon } from '../common'
import { Request } from '../../hooks/request-query'
import { StripeFormLinks } from './Form'

const PRESET_AMOUNTS = [currency(16), currency(32), currency(64), currency(128)]
const DEFAULT_AMOUNT = currency(16)

export type FooterFormProps = {
  request: Request
  links: StripeFormLinks
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
}

const FooterForm = ({
  request,
  links,
  userSignedIn,
  captchaRequired,
  recaptchaSiteKey,
}: FooterFormProps): JSX.Element => {
  const [currentAmount, setCurrentAmount] = useState(DEFAULT_AMOUNT)
  const [customAmount, setCustomAmount] = useState('')
  const [modalOpen, setModalOpen] = useState(false)

  const handleAmountChange = useCallback((amount) => {
    if (isNaN(amount.value)) {
      return setCurrentAmount(DEFAULT_AMOUNT)
    }

    setCustomAmount('')
    setCurrentAmount(amount)
  }, [])

  const handleCustomAmountChange = useCallback((amount) => {
    if (isNaN(amount.value)) {
      setCurrentAmount(DEFAULT_AMOUNT)
      setCustomAmount('')

      return
    }

    setCustomAmount(amount)
    setCurrentAmount(amount)
  }, [])

  const handleSubmit = useCallback((e) => {
    e.preventDefault()

    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <>
      <form
        onSubmit={handleSubmit}
        className="donations-form flex flex-col md:flex-row items-stretch"
      >
        <div className="amounts mb-16 md:mb-0">
          {PRESET_AMOUNTS.map((amount) => (
            <AmountButton
              key={amount.value}
              value={amount}
              onClick={handleAmountChange}
              selected={
                customAmount === '' && amount.value === currentAmount.value
              }
              className="btn-m"
            />
          ))}
          <CustomAmountInput
            onChange={handleCustomAmountChange}
            selected={customAmount !== ''}
            placeholder="Custom amount"
            value={customAmount}
          />
        </div>
        <button className="btn-m continue-btn w-100 md:w-auto md:h-auto md:ml-32">
          <span>Continue</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      </form>
      <FormModal
        open={modalOpen}
        onClose={handleModalClose}
        amount={currentAmount}
        request={request}
        userSignedIn={userSignedIn}
        captchaRequired={captchaRequired}
        recaptchaSiteKey={recaptchaSiteKey}
        links={links}
      />
    </>
  )
}
export default FooterForm
