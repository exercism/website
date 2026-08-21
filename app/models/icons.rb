# Builds URLs for icons hosted in the icons bucket.
#
# Lots of exercises and tracks have never had an icon drawn for them. Without a
# check here we'd emit a URL for a file that doesn't exist, the browser would
# request it and get a 403, and only then would our onerror handlers swap in the
# fallback. S3 errors aren't cacheable at the CDN, so every page view hits the
# origin again: those missing icons were generating millions of requests a week.
#
# So we consult the manifest of icons that really exist and point straight at
# the local fallback asset when there isn't one.
module Icons
  extend Propshaft::Helper

  MISSING_EXERCISE_ICON = "graphics/missing-exercise.svg".freeze
  MISSING_TRACK_ICON = "graphics/missing-track.svg".freeze

  def self.url_for(path, fallback:)
    return fallback_url(fallback) unless exists?(path)

    "#{Exercism.config.website_icons_host}/#{path}"
  end

  def self.exists?(path)
    manifest = Icons::RetrieveManifest.()

    # An empty manifest means we couldn't retrieve it. Assume the icon exists.
    return true if manifest.empty?

    manifest.include?(path)
  end

  def self.fallback_url(fallback)
    "#{Rails.application.config.action_controller.asset_host}#{compute_asset_path(fallback)}"
  end
end
