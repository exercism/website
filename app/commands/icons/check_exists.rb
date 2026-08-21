# Checks whether an icon actually exists in the icons bucket.
class Icons::CheckExists
  include Mandate

  initialize_with :path

  def call
    # An empty manifest means we couldn't retrieve it, so assume the icon exists
    # and leave the browser's onerror handler to fall back if it doesn't.
    return true if manifest.empty?

    manifest.include?(path)
  end

  private
  memoize
  def manifest = Icons::RetrieveManifest.()
end
