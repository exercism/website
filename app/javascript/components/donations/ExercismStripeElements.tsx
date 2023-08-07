import React from 'react'
import {
  BaseStripeElementsOptions,
  StripeElementsOptions,
} from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { useStripeFormTheme } from './stripe-form/useStripeFormTheme'
import { useLazyLoadStripe } from './stripe-form/useLazyLoadStripe'

const lightColors = {
  colorPrimary: '#130B43',
  colorText: '#130B43',
  colorBackground: '#FBFCFE',
}

const darkColors = {
  colorPrimary: '#f0f3f9',
  colorText: '#f0f3f9',
  colorBackground: '#211D2F',
}

export const appearance: BaseStripeElementsOptions['appearance'] = {
  theme: 'none',
  variables: {
    fontSizeBase: '16px',
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
  OPTIONS.appearance = {
    ...appearance,
    variables:
      useStripeFormTheme() === 'light'
        ? { ...lightColors, ...appearance.variables }
        : { ...darkColors, ...appearance.variables },
  }
  OPTIONS.amount = amount

  const { stripe, error } = useLazyLoadStripe()

  if (error) return <div className="c-alert--danger m-12">{error}</div>
  if (!stripe) return <div className="c-alert m-12">Loading...</div>

  return (
    <Elements stripe={stripe} options={OPTIONS}>
      {children}
    </Elements>
  )
}
