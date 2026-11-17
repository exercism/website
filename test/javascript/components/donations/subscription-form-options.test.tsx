import React from 'react'
import { render, screen } from '@testing-library/react'
import currency from 'currency.js'
import { FormOptions } from '@/components/donations/subscription-form/FormOptions'

test('shows change amount, update card and cancel links', () => {
  render(
    <FormOptions
      amount={currency(10)}
      links={{
        cancel: '/cancel',
        update: '/update',
        updateCard: '/settings/stripe_billing_portal',
      }}
    />
  )

  expect(
    screen.getByRole('link', { name: 'update your card' })
  ).toHaveAttribute('href', '/settings/stripe_billing_portal')
  expect(screen.getByText('Change amount')).toBeTruthy()
  expect(screen.getByText('cancel your donation')).toBeTruthy()
  expect(document.querySelector('.options')?.textContent).toBe(
    'Change amount, update your card or cancel your donation'
  )
})
