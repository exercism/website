import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'
import { FormModal } from './footer-form/FormModal'
import { GraphicalIcon } from '../common'
import { Request } from '../../hooks/request-query'

type Links = {
  settings: string
}

const PRESET_AMOUNTS = [currency(10), currency(20), currency(50), currency(100)]
const DEFAULT_AMOUNT = currency(10)

const FooterForm = ({
  request,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element => {
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
      <form onSubmit={handleSubmit} className="donations-form">
        <div className="amounts">
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
        <button className="btn-m continue-btn ml-32">
          <span>Continue</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      </form>
      <FormModal
        open={modalOpen}
        onClose={handleModalClose}
        amount={currentAmount}
        request={request}
        links={links}
      />
    </>
  )
}
export default FooterForm
