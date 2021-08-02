import React from 'react'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'

type Props = {
  amountInDollars: number
  presetAmountsInDollars: number[]
  onAmountChange: (value: number) => void
}

export const TransactionForm = ({
  amountInDollars,
  presetAmountsInDollars,
  onAmountChange,
  children,
}: React.PropsWithChildren<Props>): JSX.Element => {
  return (
    <React.Fragment>
      <div>
        {children}
        <div className="amounts">
          <div className="preset-amounts">
            {presetAmountsInDollars.map((amount) => (
              <AmountButton
                key={amount}
                value={amount}
                onClick={onAmountChange}
                current={amountInDollars}
              />
            ))}
          </div>

          <h3>Or specify a custom amount:</h3>
          <CustomAmountInput
            onChange={onAmountChange}
            selected={!presetAmountsInDollars.includes(amountInDollars)}
          />
        </div>
      </div>
    </React.Fragment>
  )
}
