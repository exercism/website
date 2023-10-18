import React, { useMemo } from 'react'
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
  theme: 'stripe',
  variables: {
    fontSizeBase: '16px',
    fontFamily: 'Poppins, sans-serif',
    fontSmooth: 'antialiased',
    fontWeightNormal: '500',
    colorDanger: '#D03B3B',
    colorTextPlaceholder: '#76709F',
    borderRadius: '8px',
  },
}

export const ExercismStripeElements = ({
  children,
  amount = 3200,
  mode,
}: {
  children?: React.ReactNode
  amount: number
  mode: 'subscription' | 'payment'
}): JSX.Element | null => {
  const theme = useStripeFormTheme()

  const options: StripeElementsOptions = useMemo(
    () => ({
      mode,
      amount,
      currency: 'usd',
      setup_future_usage: mode === 'subscription' ? 'off_session' : null,
      appearance: {
        ...appearance,
        variables:
          theme === 'light'
            ? { ...lightColors, ...appearance.variables }
            : { ...darkColors, ...appearance.variables },
      },
      fonts: [
        {
          cssSrc:
            'https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap',
        },
      ],
    }),
    [mode, amount, theme]
  )

  const { stripe, error } = useLazyLoadStripe()

  if (error) return <div className="c-alert--danger my-12 mx-24">{error}</div>
  if (!stripe) return <div className="c-alert my-12 mx-24">Loading…</div>

  return (
    <Elements stripe={stripe} options={options}>
      {children}
    </Elements>
  )
}
