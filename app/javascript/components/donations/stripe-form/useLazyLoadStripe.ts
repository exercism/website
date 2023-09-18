import { useState, useEffect } from 'react'
import Bugsnag from '@bugsnag/browser'
import { Stripe } from '@stripe/stripe-js'

export function useLazyLoadStripe(): {
  stripe: Stripe | null
  error: string | null
} {
  const [stripe, setStripe] = useState<Stripe | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const publishableKey = document.querySelector<HTMLMetaElement>(
      'meta[name="stripe-publishable-key"]'
    )?.content

    if (!publishableKey) {
      Bugsnag.notify('Publishable key not found!')
      setError('Publishable key not found!')
      return
    }

    import('@stripe/stripe-js')
      .then(({ loadStripe }) => {
        if (loadStripe) {
          return loadStripe(publishableKey)
        } else {
          throw new Error('loadStripe method not found')
        }
      })
      .then(setStripe)
      .catch((err) => {
        Bugsnag.notify('Failed to load Stripe:', err)
        setError(`Failed to load Stripe. Please reload the page to try again.`)
      })
  }, [])

  return { stripe, error }
}
