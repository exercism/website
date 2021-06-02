# Load the Rails application.
require_relative 'application'

# Rails is very pinickity over this being set and really
# really wants it to be an ENV var. So let's just give it
# its way, even though this is pretty ugly.
ENV["SECRET_KEY_BASE"] = Exercism.secrets.website_secret_key_base
ENV["SKYLIGHT_AUTHENTICATION"] = Exercism.secrets.skylight_key

# Initialize the Rails application.
Rails.application.initialize!
