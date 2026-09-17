# Rewrites a path (with or without a query string) to the same page in
# another locale. English is naked.
class Locale::SwapInPath
  include Mandate

  initialize_with :fullpath, :locale

  def call
    path, query = fullpath.to_s.split("?", 2)
    segments = path.to_s.split("/").reject(&:empty?)

    # Only an exact roster locale is a prefix. "pt-is-great" or a track
    # called "hu-lang" merely shares letters with one.
    segments.shift if LocaleRoster.known?(segments.first)
    segments.unshift(LocaleRoster.path_segment(locale))

    ["/#{segments.compact.join('/')}", query.presence].compact.join("?")
  end
end
