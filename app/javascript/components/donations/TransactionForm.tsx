import currency from 'currency.js'
import React from 'react'
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
                onClick={onAmountChange}
                current={currentAmount}
                className="btn-l btn-enhanced"
              />
            ))}
          </div>

          <h3>Or specify a custom amount:</h3>
          <CustomAmountInput
            onChange={onAmountChange}
            selected={
              !presetAmounts.map((a) => a.value).includes(currentAmount.value)
            }
            placeholder="Specify amount"
          />
        </div>
      </div>
    </React.Fragment>
  )
}
