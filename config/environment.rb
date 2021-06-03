# Load the Rails application.
require_relative 'application'

# Rails is very pinickity over this being set and really
# really wants it to be an ENV var. So let's just give it
# its way, even though this is pretty ugly.
ENV["SECRET_KEY_BASE"] = Exercism.secrets.website_secret_key_base

begin
  ref = File.read(Rails.root.join(".git", "HEAD")) # This gives `ref: refs/heads/main`
  path = ref.split(':').last.strip # This extracts `refs/heads/main`
  ENV["SKYLIGHT_DEPLOY_GIT_SHA"] = File.read(Rails.root.join(".git", path)).strip
rescue StandardError => e
  Bugsnag.notify(e)
end

# Initialize the Rails application.
Rails.application.initialize!
