if Rails.env.production?
  Bugsnag.configure do |config|
    config.api_key = "5564ad0d9fde96c4378bc555eaf88313"
    config.notify_release_stages = ["production"]
  end
end
