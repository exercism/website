require 'stripe'

# TODO: (Blocking) Use exercism config
Stripe.api_key = 'sk_test_51IDGMXEoOT0Jqx0UMSRriKkjutiuKVsv8GWUQWqhz4df03e4fuHfJddhwCFwbGrSLWhAUjFWPUPfsFIoyxYiRj0Y003RB7tZXj'

module Donations
  STRIPE_PRODUCT_ID = "prod_Jobed6hLiuIq71".freeze
end
