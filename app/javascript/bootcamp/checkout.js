import { loadStripe } from '@stripe/stripe-js'

if (window.location.pathname.match(/\/courses\/[\w-]+\/pay/)) {
  initialize()
}

async function initialize() {
  const stripeMetaTag = 'meta[name="stripe-publishable-key"]'
  const publishableKey = document.querySelector(stripeMetaTag)

  if (!publishableKey) {
    console.log(`%cCouldn't find ${stripeMetaTag}`, 'color: yellow')
    return
  }

  const stripe = await loadStripe(publishableKey.content)

  const fetchClientSecret = async () => {
    const response = await fetch('/courses/stripe/create-checkout-session', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data.clientSecret
  }

  const checkout = await stripe.initEmbeddedCheckout({
    fetchClientSecret,
  })

  checkout.mount('#checkout')
}
