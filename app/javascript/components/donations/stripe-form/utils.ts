import currency from 'currency.js'
import { PaymentIntentType } from './useStripeForm'

export function generateStripeButtonText(
  paymentIntent: PaymentIntentType,
  amount: currency
): string {
  switch (paymentIntent) {
    case 'payment':
      return `Donate ${amount.format()} to Exercism`
    case 'subscription':
      return `Donate ${amount.format()} to Exercism monthly`
    case 'premium_monthly_subscription':
      return 'Subscribe to Premium'
    case 'premium_yearly_subscription':
      return 'Subscribe to Premium'
    default:
      return ''
  }
}

export function generateIntervalText(paymentIntent: PaymentIntentType): string {
  switch (paymentIntent) {
    case 'premium_monthly_subscription':
      return 'month'
    case 'premium_yearly_subscription':
      return 'year'
    default:
      return ''
  }
}
