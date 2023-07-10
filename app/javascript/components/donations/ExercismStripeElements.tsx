import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import React from 'react'
import Bugsnag from '@bugsnag/browser'

const stripe = load()

function load() {
  const publishableKey = document.querySelector<HTMLMetaElement>(
    'meta[name="stripe-publishable-key"]'
  )?.content

  if (!publishableKey) {
    Bugsnag.notify('Publishable key not found!')

    return
  }

  return loadStripe(publishableKey)
}

const options = {
  mode: 'payment',
  amount: 1234,
  currency: 'usd',
}

export const ExercismStripeElements = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element | null => {
  if (stripe === undefined) {
    return null
  }

  return (
    <Elements stripe={stripe} options={options}>
      {children}
    </Elements>
  )
}
