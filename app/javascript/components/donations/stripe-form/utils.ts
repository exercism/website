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
    default:
      return ''
  }
}
