require 'stripe'

Stripe.api_key = Exercism.secrets.stripe_secret_key
Stripe.api_version = '2024-10-28.acacia'
