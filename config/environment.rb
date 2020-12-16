# Load the Rails application.
require_relative 'application'

# Set secrets from Exercism secrets
Rails.application.secrets.secret_key_base =
  Exercism.secrets.website_secret_key_base

# Initialize the Rails application.
Rails.application.initialize!
