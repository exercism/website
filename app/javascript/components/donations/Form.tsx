import React, { useState, createContext } from 'react'
import { PaymentIntentType } from './StripeForm'
import { Tab, TabContext } from '../common/Tab'
import { TransactionForm } from './TransactionForm'
import { ExistingSubscriptionNotice } from './ExistingSubscriptionNotice'

const TabsContext = createContext<TabContext>({
  current: 'subscription',
  switchToTab: () => {},
})

export const Form = ({
  existingSubscriptionAmountinDollars,
  onSuccess,
}: {
  existingSubscriptionAmountinDollars: number | null
  onSuccess: (type: PaymentIntentType, amountInDollars: number) => void
}): JSX.Element => {
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    'subscription'
  )

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
              transactionType="subscription"
              defaultAmountInDollars={32}
              presetAmountsInDollars={[16, 32, 64, 128]}
              onSuccess={onSuccess}
            >
              {existingSubscriptionAmountinDollars != null ? (
                <ExistingSubscriptionNotice
                  amountInDollars={existingSubscriptionAmountinDollars}
                  onExtraDonation={() => setTransactionType('payment')}
                />
              ) : null}
            </TransactionForm>
          </Tab.Panel>
          <Tab.Panel id="payment" context={TabsContext}>
            <TransactionForm
              transactionType="payment"
              defaultAmountInDollars={32}
              presetAmountsInDollars={[32, 128, 256, 512]}
              onSuccess={onSuccess}
            />
          </Tab.Panel>
        </div>
      </div>
    </TabsContext.Provider>
  )
}
