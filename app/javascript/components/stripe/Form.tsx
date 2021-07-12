import React from 'react'
import { loadStripe } from '@stripe/stripe-js'

import { SubscriptionForm } from './SubscriptionForm'
import { OneOffForm } from './OneOffForm'

// Make sure to call `loadStripe` outside of a component’s render to avoid
// recreating the `Stripe` object on every render.
const stripePromise = loadStripe(
  'pk_test_51IDGMXEoOT0Jqx0UcoKlkvB7O0VDvFdCBvOCiWiKv6CkSnkZn7IG6cIHuCWg7cegGogYJSy8WsaKzwFHQqN75T7b00d56MtilB'
)

export function Form({}: {}) {
  return (
    <Elements stripe={stripePromise}>
      <SubscriptionForm />
      <OneOffForm />
    </Elements>
  )
}
