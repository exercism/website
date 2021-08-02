import React, { useState, createContext, useCallback, useMemo } from 'react'
import { PaymentIntentType } from './StripeForm'
import { Tab, TabContext } from '../common/Tab'
import { TransactionForm } from './TransactionForm'
import { ExistingSubscriptionNotice } from './ExistingSubscriptionNotice'
import { ExercismStripeElements } from './donation-form/ExercismStripeElements'
import { StripeForm } from './StripeForm'

const TabsContext = createContext<TabContext>({
  current: 'subscription',
  switchToTab: () => {},
})

type Links = {
  settings: string
}

const PAYMENT_DEFAULT_AMOUNT_IN_DOLLARS = 32
const SUBSCRIPTION_DEFAULT_AMOUNT_IN_DOLLARS = 32

export const Form = ({
  existingSubscriptionAmountinDollars,
  onSuccess,
  links,
}: {
  existingSubscriptionAmountinDollars: number | null
  onSuccess: (type: PaymentIntentType, amountInDollars: number) => void
  links: Links
}): JSX.Element => {
  const [amountInDollars, setAmountInDollars] = useState({
    subscription: SUBSCRIPTION_DEFAULT_AMOUNT_IN_DOLLARS,
    payment: PAYMENT_DEFAULT_AMOUNT_IN_DOLLARS,
  })
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    existingSubscriptionAmountinDollars ? 'payment' : 'subscription'
  )

  const handleAmountChange = useCallback(
    (transactionType: PaymentIntentType) => {
      return (value: number) => {
        switch (transactionType) {
          case 'subscription':
            setAmountInDollars({
              ...amountInDollars,
              subscription: isNaN(value)
                ? SUBSCRIPTION_DEFAULT_AMOUNT_IN_DOLLARS
                : value,
            })

            break
          case 'payment':
            setAmountInDollars({
              ...amountInDollars,
              payment: isNaN(value) ? PAYMENT_DEFAULT_AMOUNT_IN_DOLLARS : value,
            })

            break
        }
      }
    },
    [amountInDollars]
  )

  const currentAmountInDollars = useMemo(() => {
    switch (transactionType) {
      case 'payment':
        return amountInDollars.payment
      case 'subscription':
        return amountInDollars.subscription
    }
  }, [amountInDollars, transactionType])

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
              amountInDollars={amountInDollars.subscription}
              onAmountChange={handleAmountChange('subscription')}
              presetAmountsInDollars={[16, 32, 64, 128]}
            >
              {existingSubscriptionAmountinDollars != null ? (
                <ExistingSubscriptionNotice
                  amountInDollars={existingSubscriptionAmountinDollars}
                  onExtraDonation={() => setTransactionType('payment')}
                  links={links}
                />
              ) : null}
            </TransactionForm>
          </Tab.Panel>
          <Tab.Panel id="payment" context={TabsContext}>
            <TransactionForm
              amountInDollars={amountInDollars.payment}
              onAmountChange={handleAmountChange('payment')}
              presetAmountsInDollars={[32, 128, 256, 512]}
            />
          </Tab.Panel>
          <ExercismStripeElements>
            <StripeForm
              paymentIntentType={transactionType}
              amountInDollars={currentAmountInDollars}
              onSuccess={onSuccess}
            />
          </ExercismStripeElements>
        </div>
      </div>
    </TabsContext.Provider>
  )
}
