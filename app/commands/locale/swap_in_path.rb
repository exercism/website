class Locale::SwapInPath
  include Mandate

  initialize_with :fullpath, :locale

  def call
    path, query = fullpath.to_s.split("?", 2)
    segments = path.to_s.split("/").reject(&:empty?)

    segments.shift if LocaleRoster.known?(segments.first)
    segments.unshift(LocaleRoster.path_segment(locale))

    ["/#{segments.compact.join('/')}", query.presence].compact.join("?")
  end
end
