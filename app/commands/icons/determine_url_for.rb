# Builds the URL for an icon hosted in the icons bucket.
#
# Lots of exercises and tracks have never had an icon drawn for them. Without a
# check here we'd emit a URL for a file that doesn't exist, the browser would
# request it and get a 403, and only then would our onerror handlers swap in the
# fallback. S3 errors aren't cacheable at the CDN, so every page view hits the
# origin again: those missing icons were generating millions of requests a week.
#
# So we point straight at the local fallback asset when there isn't an icon.
class Icons::DetermineUrlFor
  include Mandate
  include Propshaft::Helper

  MISSING_EXERCISE_ICON = "graphics/missing-exercise.svg".freeze
  MISSING_TRACK_ICON = "graphics/missing-track.svg".freeze

  initialize_with :path, :fallback

  def call
    return fallback_url unless Icons::CheckExists.(path)

    "#{Exercism.config.website_icons_host}/#{path}"
  end

  private
  def fallback_url = "#{Rails.application.config.action_controller.asset_host}#{compute_asset_path(fallback)}"
end
