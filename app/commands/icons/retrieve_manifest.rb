# Retrieves the set of icon paths that actually exist in the icons bucket.
#
# The manifest is published to the bucket by the sync workflow in the
# exercism/website-icons repo, so it updates whenever icons are added or
# removed, without needing anything deployed here.
#
# This fails open: if we can't retrieve the manifest we return an empty set,
# which callers treat as "assume everything exists". That keeps us on the old
# behaviour (request the icon, let the browser's onerror handler fall back)
# rather than rendering the fallback for every icon on the site.
class Icons::RetrieveManifest
  include Mandate

  def call
    cached = Rails.cache.read(CACHE_KEY)
    return cached if cached

    # Don't hold onto a failure for the full expiry. A blip would otherwise
    # leave us checking nothing for an hour.
    Rails.cache.write(CACHE_KEY, paths, expires_in: paths.empty? ? FAILURE_CACHE_EXPIRY : CACHE_EXPIRY)
    paths
  end

  private
  memoize
  def paths
    parsed = JSON.parse(manifest)
    raise TypeError, "Icons manifest is not an array" unless parsed.is_a?(Array)

    parsed.to_set
  rescue StandardError => e
    Sentry.capture_exception(e)
    Set.new
  end

  def manifest
    Exercism.s3_client.get_object(
      bucket: Exercism.config.aws_icons_bucket,
      key: MANIFEST_KEY
    ).body.read
  end

  CACHE_KEY = "Icons::RetrieveManifest".freeze
  MANIFEST_KEY = "manifest.json".freeze
  CACHE_EXPIRY = 1.hour.freeze
  FAILURE_CACHE_EXPIRY = 1.minute.freeze
  private_constant :CACHE_KEY, :MANIFEST_KEY, :CACHE_EXPIRY, :FAILURE_CACHE_EXPIRY
end
