import { loadStripe } from '@stripe/stripe-js'

const stripePromise = loadStripe(
  'pk_test_51IDGMXEoOT0Jqx0UcoKlkvB7O0VDvFdCBvOCiWiKv6CkSnkZn7IG6cIHuCWg7cegGogYJSy8WsaKzwFHQqN75T7b00d56MtilB'
)

if (window.location.pathname === '/bootcamp/pay') {
  initialize()
}

async function initialize() {
  const stripe = await stripePromise

  const fetchClientSecret = async () => {
    const response = await fetch('/bootcamp/stripe/create-checkout-session', {
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
