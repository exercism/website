import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'
import currency from 'currency.js'
import { StripeForm } from '@/components/donations/StripeForm'

jest.mock('@stripe/react-stripe-js', () => ({
  useStripe: () => null,
  useElements: () => null,
  CardElement: () => null,
  PaymentElement: () => <div data-testid="payment-element" />,
}))

test('renders the payment element without an email input', () => {
  render(
    <StripeForm
      paymentIntentType="payment"
      amount={currency(16)}
      onSuccess={() => null}
      captchaRequired={false}
      confirmParamsReturnUrl="/donate/donated"
    />
  )

  expect(screen.getByTestId('payment-element')).toBeInTheDocument()
  expect(screen.queryByRole('textbox')).not.toBeInTheDocument()
  expect(screen.getByRole('button')).toBeDisabled()
})
