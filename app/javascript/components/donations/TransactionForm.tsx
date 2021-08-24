import React, { useState, useCallback } from 'react'
import currency from 'currency.js'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'

type Props = {
  amount: currency
  presetAmounts: currency[]
  onAmountChange: (value: currency) => void
}

export const TransactionForm = ({
  amount: currentAmount,
  presetAmounts,
  onAmountChange,
  children,
}: React.PropsWithChildren<Props>): JSX.Element => {
  const [customAmount, setCustomAmount] = useState(
    presetAmounts.map((a) => a.value).includes(currentAmount.value)
      ? ''
      : currentAmount
  )

  const handleAmountButtonChange = useCallback(
    (amount) => {
      setCustomAmount('')
      onAmountChange(amount)
    },
    [onAmountChange]
  )

  const handleCustomAmountChange = useCallback(
    (amount) => {
      if (isNaN(amount.value)) {
        setCustomAmount('')
        onAmountChange(amount)

        return
      }

      setCustomAmount(amount)
      onAmountChange(amount)
    },
    [onAmountChange]
  )

  return (
    <React.Fragment>
      <div>
        {children}
        <div className="amounts">
          <div className="preset-amounts">
            {presetAmounts.map((amount) => (
              <AmountButton
                key={amount.value}
                value={amount}
                onClick={handleAmountButtonChange}
                selected={
                  customAmount === '' && amount.value === currentAmount.value
                }
                className="btn-l btn-enhanced"
              />
            ))}
          </div>

          <h3>Or specify a custom amount:</h3>
          <CustomAmountInput
            onChange={handleCustomAmountChange}
            selected={customAmount !== ''}
            placeholder="Specify amount"
            value={customAmount}
          />
        </div>
      </div>
    </React.Fragment>
  )
}
