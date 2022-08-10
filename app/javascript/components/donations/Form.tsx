import React, { useState, createContext, useCallback, useMemo } from 'react'
import { PaymentIntentType } from './StripeForm'
import { Tab, TabContext } from '../common/Tab'
import { TransactionForm } from './TransactionForm'
import { ExistingSubscriptionNotice } from './ExistingSubscriptionNotice'
import { ExercismStripeElements } from './ExercismStripeElements'
import { StripeForm } from './StripeForm'
import currency from 'currency.js'
import { Request, useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { useQueryCache } from 'react-query'

const TabsContext = createContext<TabContext>({
  current: 'subscription',
  switchToTab: () => null,
})

type Links = {
  settings: string
}

type FormAmount = {
  subscription: currency
  payment: currency
}

type Subscription = {
  amountInCents: number
}

const PAYMENT_DEFAULT_AMOUNT = currency(32)
const SUBSCRIPTION_DEFAULT_AMOUNT = currency(32)

const DEFAULT_ERROR = new Error('Unable to fetch subscription information')

export const Form = ({
  request,
  defaultAmount,
  defaultTransactionType,
  onSuccess,
  links,
  userSignedIn,
  onProcessing = () => null,
  onSettled = () => null,
  id,
}: {
  request: Request
  defaultAmount?: Partial<FormAmount>
  defaultTransactionType?: PaymentIntentType
  onSuccess: (type: PaymentIntentType, amount: currency) => void
  userSignedIn: boolean
  onProcessing?: () => void
  onSettled?: () => void
  links: Links
  id?: string
}): JSX.Element => {
  const queryCache = useQueryCache()
  const { data, status, error } = useRequestQuery<{
    subscription: Subscription
  }>('active-subscription', request)
  const [amount, setAmount] = useState({
    subscription: SUBSCRIPTION_DEFAULT_AMOUNT,
    payment: PAYMENT_DEFAULT_AMOUNT,
    ...defaultAmount,
  })
  const [transactionType, setTransactionType] = useState<PaymentIntentType>(
    defaultTransactionType || (data?.subscription ? 'payment' : 'subscription')
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

  const handleSuccess = useCallback(
    (type, amount) => {
      if (type === 'subscription') {
        queryCache.setQueryData('active-subscription', () => {
          return {
            subscription: {
              amountInCents: amount.intValue,
            },
          }
        })
      }

      onSuccess(type, amount)
    },
    [onSuccess, queryCache]
  )

  return (
    <TabsContext.Provider
      value={{
        current: transactionType,
        switchToTab: (id) => setTransactionType(id as PaymentIntentType),
      }}
    >
      <div id={id} className="c-donations-form">
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
            <FetchingBoundary
              status={status}
              error={error}
              defaultError={DEFAULT_ERROR}
            >
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
                {data?.subscription != null ? (
                  <ExistingSubscriptionNotice
                    amount={currency(data.subscription?.amountInCents, {
                      fromCents: true,
                    })}
                    onExtraDonation={() => setTransactionType('payment')}
                    links={links}
                  />
                ) : null}
              </TransactionForm>
            </FetchingBoundary>
          </Tab.Panel>
          <Tab.Panel id="payment" context={TabsContext}>
            <TransactionForm
              amount={amount.payment}
              onAmountChange={handleAmountChange('payment')}
              presetAmounts={[
                currency(16),
                currency(32),
                currency(64),
                currency(128),
              ]}
            />
          </Tab.Panel>
          <ExercismStripeElements>
            <StripeForm
              paymentIntentType={transactionType}
              userSignedIn={userSignedIn}
              amount={currentAmount}
              onSuccess={handleSuccess}
              onProcessing={onProcessing}
              onSettled={onSettled}
            />
          </ExercismStripeElements>
        </div>
      </div>
    </TabsContext.Provider>
  )
}
