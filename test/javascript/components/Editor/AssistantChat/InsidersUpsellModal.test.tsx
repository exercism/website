import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'
import { InsidersUpsellModal } from '@/components/editor/AssistantChat/InsidersUpsellModal'

jest.mock('@/components/donations/ExercismStripeElements', () => ({
  ExercismStripeElements: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="stripe-elements">{children}</div>
  ),
}))
jest.mock('@/components/donations/StripeForm', () => ({
  StripeForm: () => <div data-testid="stripe-form" />,
}))

const config = {
  userSignedIn: true,
  captchaRequired: false,
  recaptchaSiteKey: '',
  links: {
    insiders: '/insiders',
    join: '/insiders/join?return_to=%2Ftracks%2Fjq%2Fexercises%2Fhello-world%2Fedit',
    paymentPending: '/payment-pending',
  },
}

function setIsolated(value: boolean | undefined) {
  Object.defineProperty(window, 'crossOriginIsolated', {
    configurable: true,
    value,
  })
}

afterEach(() => setIsolated(undefined))

test('renders the inline Stripe form on an ordinary page', () => {
  setIsolated(false)
  render(<InsidersUpsellModal config={config} open={true} onClose={() => {}} />)

  expect(screen.getByTestId('stripe-form')).toBeInTheDocument()
  expect(screen.queryByText('Become an Insider')).not.toBeInTheDocument()
})

test('links out to the Insiders page on a cross-origin isolated page', () => {
  // Stripe Elements are cross-origin iframes, which an isolated page blocks.
  setIsolated(true)
  render(<InsidersUpsellModal config={config} open={true} onClose={() => {}} />)

  expect(screen.queryByTestId('stripe-form')).not.toBeInTheDocument()
  expect(screen.getByText('Become an Insider')).toHaveAttribute(
    'href',
    '/insiders/join?return_to=%2Ftracks%2Fjq%2Fexercises%2Fhello-world%2Fedit'
  )
})
