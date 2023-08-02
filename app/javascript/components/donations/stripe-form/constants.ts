import { StripeCardElementOptions } from '@stripe/stripe-js'

const options = {
  style: {
    base: {
      backgroundColor: 'transparent',
      padding: '8px',
      color: 'grey',
      fontFamily: 'Poppins, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      lineHeight: '32px',
      fontWeight: '500',
      '::placeholder': {
        color: '#76709F',
      },
    },
    invalid: {
      color: '#D03B3B',
      iconColor: '#D03B3B',
    },
  },
}
const lightColors = {
  colorText: '#130B43',
  colorPlaceholder: '#76709F',
}

const darkColors = {
  colorText: '#f0f3f9',
  colorPlaceholder: '#f0f3f9bb',
}

export function generateCardOptions(
  stripeFormTheme: 'light' | 'dark'
): StripeCardElementOptions {
  const colors = stripeFormTheme === 'light' ? lightColors : darkColors
  options.style.base.color = colors.colorText
  options.style.base['::placeholder'].color = colors.colorPlaceholder

  return options
}
