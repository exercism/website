import React from 'react'
import { render, screen } from '@testing-library/react'
import currency from 'currency.js'
import { ExistingSubscriptionNotice } from '@/components/donations/ExistingSubscriptionNotice'

const renderNotice = (links: { settings: string; updateCard?: string }) =>
  render(
    <ExistingSubscriptionNotice
      amount={currency(10)}
      onExtraDonation={() => null}
      links={links}
    />
  )

test('links to the Stripe-hosted page when an update-card link is given', () => {
  renderNotice({
    settings: '/settings/donations',
    updateCard: '/settings/stripe_billing_portal',
  })

  expect(
    screen.getByRole('link', { name: 'use this Stripe-hosted page' })
  ).toHaveAttribute('href', '/settings/stripe_billing_portal')
})

test('does not show the update-card text without an update-card link', () => {
  renderNotice({ settings: '/settings/donations' })

  expect(screen.queryByText(/To update your card/)).toBeNull()
})
