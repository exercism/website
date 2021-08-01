import React, { useState } from 'react'
import { ExercismStripeElements } from './donation-form/ExercismStripeElements'
import { StripeForm } from './StripeForm'
import { PaymentIntentType } from './StripeForm'
import { AmountButton } from './donation-form/AmountButton'
import { CustomAmountInput } from './donation-form/CustomAmountInput'

type Props = {
  defaultAmountInDollars: number
  presetAmountsInDollars: number[]
  transactionType: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amountInDollars: number) => void
}

export const TransactionForm = ({
  defaultAmountInDollars,
  presetAmountsInDollars,
  transactionType,
  onSuccess,
  children,
}: React.PropsWithChildren<Props>): JSX.Element => {
  const [amountInDollars, setAmountInDollars] = useState(defaultAmountInDollars)

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
                onClick={setAmountInDollars}
                current={amountInDollars}
              />
            ))}
          </div>

          <h3>Or specify a custom amount:</h3>
          <CustomAmountInput
            onChange={setAmountInDollars}
            defaultAmount={defaultAmountInDollars}
            selected={!presetAmountsInDollars.includes(amountInDollars)}
          />
        </div>
      </div>
      <ExercismStripeElements>
        <StripeForm
          paymentIntentType={transactionType}
          amountInDollars={amountInDollars}
          onSuccess={onSuccess}
        />
      </ExercismStripeElements>
    </React.Fragment>
  )
}
