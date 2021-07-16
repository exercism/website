require 'stripe'

# TODO: (Blocking) Use exercism config secrets
Stripe.api_key = 'sk_test_51IDGMXEoOT0Jqx0UMSRriKkjutiuKVsv8GWUQWqhz4df03e4fuHfJddhwCFwbGrSLWhAUjFWPUPfsFIoyxYiRj0Y003RB7tZXj'

module Exercism
  # TODO: (Blocking) Use exercism config secrets
  STRIPE_RECURRING_PRODUCT_ID = "prod_JreBkyrktcXdOJ".freeze

  # TODO: Use Exercism config for this with an ENV var for local testing
  STRIPE_ENDPOINT_SECRET = "whsec_rgY246H0vSUw0A9KpDOqsDDgAakEdCCT".freeze
end
