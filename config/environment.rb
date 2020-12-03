# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Set secrets from Exercism secrets
Rails.application.secrets.secret_key_base =
  Exercism.secrets.website_secret_key_base
