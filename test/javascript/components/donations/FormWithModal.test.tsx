import React from 'react'
import { render } from '@testing-library/react'
import FormWithModal from '@/components/donations/FormWithModal'
import { useTrackPaymentPrompt } from '@/hooks/use-track-payment-prompt'

jest.mock('@/components/donations/Form', () => ({
  Form: () => <div data-testid="donation-form" />,
}))
jest.mock('@/components/donations/SuccessModal', () => () => null)
jest.mock('@/hooks/use-track-payment-prompt', () => ({
  useTrackPaymentPrompt: jest.fn(),
}))

test('renders and records the payment prompt', () => {
  const { getByTestId } = render(
    <FormWithModal
      request={{ endpoint: '/api/v2/payments/subscriptions/current' }}
      links={{ success: '/donated', settings: '/settings/donations' }}
      captchaRequired={false}
      recaptchaSiteKey=""
    />
  )

  expect(getByTestId('donation-form')).toBeTruthy()
  expect(useTrackPaymentPrompt).toHaveBeenCalledWith('donations_page')
})
