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
  fonts: [
    {
      cssSrc:
        'https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap',
    },
  ],
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
