import React from 'react'
import {
  BaseStripeElementsOptions,
  StripeElementsOptions,
  loadStripe,
} from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import Bugsnag from '@bugsnag/browser'
import { useThemeObserver } from '@/hooks'

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

const lightAppearance: BaseStripeElementsOptions['appearance'] = {
  theme: 'none',
  variables: {
    fontSizeBase: '16px',
    colorPrimary: '#130B43',
    colorText: '#130B43',
    colorBackground: '#FBFCFE',
    fontFamily: 'Poppins, sans-serif',
    fontSmooth: 'antialiased',
    fontLineHeight: '32px',
    fontWeightNormal: '500',
    colorDanger: '#D03B3B',
    colorTextPlaceholder: '#76709F',
  },
}

const darkAppearance: BaseStripeElementsOptions['appearance'] = {
  theme: 'none',
  variables: {
    fontSizeBase: '16px',
    colorPrimary: '#f0f3f9',
    colorText: '#f0f3f9',
    colorBackground: '#211D2F',
    fontFamily: 'Poppins, sans-serif',
    fontSmooth: 'antialiased',
    fontLineHeight: '32px',
    fontWeightNormal: '500',
    colorDanger: '#D03B3B',
    colorTextPlaceholder: '#76709F',
  },
}

const OPTIONS: StripeElementsOptions = {
  mode: 'payment',
  amount: 3200,
  currency: 'usd',
  setup_future_usage: 'off_session',
  fonts: [
    {
      cssSrc:
        'https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap',
    },
  ],
}

export const ExercismStripeElements = ({
  children,
  amount = 3200,
}: {
  children?: React.ReactNode
  amount: number
}): JSX.Element | null => {
  const { explicitTheme } = useThemeObserver()
  if (stripe === undefined) {
    return null
  }

  OPTIONS.appearance =
    explicitTheme === 'theme-light' ? lightAppearance : darkAppearance
  OPTIONS.amount = amount

  return (
    <Elements stripe={stripe} options={OPTIONS}>
      {children}
    </Elements>
  )
}
