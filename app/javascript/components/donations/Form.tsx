import React, { useState, createContext, useCallback, useMemo } from 'react'
import { PaymentIntentType } from './StripeForm'
import { Tab, TabContext } from '../common/Tab'
import { TransactionForm } from './TransactionForm'
import { ExistingSubscriptionNotice } from './ExistingSubscriptionNotice'
import { ExercismStripeElements } from './donation-form/ExercismStripeElements'
import { StripeForm } from './StripeForm'
import currency from 'currency.js'

const TabsContext = createContext<TabContext>({
  current: 'subscription',
  switchToTab: () => {},
})

type Links = {
  settings: string
}

const PAYMENT_DEFAULT_AMOUNT = currency(32)
const SUBSCRIPTION_DEFAULT_AMOUNT = currency(32)

export const Form = ({
  existingSubscriptionAmount,
  onSuccess,
  links,
}: {
  existingSubscriptionAmount: currency | null
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  links: Links
}): JSX.Element => {
  const [amount, setAmount] = useState({
    subscription: SUBSCRIPTION_DEFAULT_AMOUNT,
    payment: PAYMENT_DEFAULT_AMOUNT,
  })
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    existingSubscriptionAmount ? 'payment' : 'subscription'
  )

  const handleAmountChange = useCallback(
    (transactionType: PaymentIntentType) => {
      return (newAmount: currency) => {
        switch (transactionType) {
          case 'subscription':
            setAmount({
              ...amount,
              subscription: isNaN(newAmount.value)
                ? SUBSCRIPTION_DEFAULT_AMOUNT
                : newAmount,
            })

            break
          case 'payment':
            setAmount({
              ...amount,
              payment: isNaN(newAmount.value)
                ? PAYMENT_DEFAULT_AMOUNT
                : newAmount,
            })

            break
        }
      }
    },
    [amount]
  )

  const currentAmount = useMemo(() => {
    switch (transactionType) {
      case 'payment':
        return amount.payment
      case 'subscription':
        return amount.subscription
    }
  }, [amount, transactionType])

  return (
    <TabsContext.Provider
      value={{
        current: transactionType,
        switchToTab: (id) => setTransactionType(id as PaymentIntentType),
      }}
    >
      <div className="c-donations-form">
        <div className="--tabs">
          <Tab id="subscription" context={TabsContext}>
            💙 Monthly
          </Tab>
          <Tab id="payment" context={TabsContext}>
            One-off
          </Tab>
        </div>
        <div className="--content">
          <Tab.Panel id="subscription" context={TabsContext}>
            <TransactionForm
              amount={amount.subscription}
              onAmountChange={handleAmountChange('subscription')}
              presetAmounts={[
                currency(16),
                currency(32),
                currency(64),
                currency(128),
              ]}
            >
              {existingSubscriptionAmount != null ? (
                <ExistingSubscriptionNotice
                  amount={existingSubscriptionAmount}
                  onExtraDonation={() => setTransactionType('payment')}
                  links={links}
                />
              ) : null}
            </TransactionForm>
          </Tab.Panel>
          <Tab.Panel id="payment" context={TabsContext}>
            <TransactionForm
              amount={amount.payment}
              onAmountChange={handleAmountChange('payment')}
              presetAmounts={[
                currency(32),
                currency(128),
                currency(256),
                currency(512),
              ]}
            />
          </Tab.Panel>
          <ExercismStripeElements>
            <StripeForm
              paymentIntentType={transactionType}
              amount={currentAmount}
              onSuccess={onSuccess}
            />
          </ExercismStripeElements>
        </div>
      </div>
    </TabsContext.Provider>
  )
}
