import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'
import { StripeFormModal } from './footer-form/StripeFormModal'

const PRESET_AMOUNTS = [currency(10), currency(20), currency(50), currency(100)]
const DEFAULT_AMOUNT = currency(10)

const FooterForm = (): JSX.Element => {
  const [currentAmount, setCurrentAmount] = useState(DEFAULT_AMOUNT)
  const [modalOpen, setModalOpen] = useState(false)

  const handleAmountChange = useCallback((amount) => {
    if (isNaN(amount.value)) {
      return setCurrentAmount(DEFAULT_AMOUNT)
    }

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
    <React.Fragment>
      <form onSubmit={handleSubmit}>
        {PRESET_AMOUNTS.map((amount) => (
          <AmountButton
            key={amount.value}
            value={amount}
            onClick={handleAmountChange}
            current={currentAmount}
          />
        ))}
        <CustomAmountInput
          onChange={handleAmountChange}
          selected={
            !PRESET_AMOUNTS.map((a) => a.value).includes(currentAmount.value)
          }
          placeholder="Custom amount"
        />
        <button>Continue</button>
      </form>
      <StripeFormModal
        open={modalOpen}
        onClose={handleModalClose}
        amount={currentAmount}
      />
    </React.Fragment>
  )
}
export default FooterForm
