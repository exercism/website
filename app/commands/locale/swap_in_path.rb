class Locale::SwapInPath
  include Mandate

  initialize_with :fullpath, :locale

  def call
    path, query = fullpath.to_s.split("?", 2)
    segments = path.to_s.split("/").reject(&:empty?)

    segments.shift if served?(segments.first)
    segments.unshift(path_segment)

    ["/#{segments.compact.join('/')}", query.presence].compact.join("?")
  end

  private
  def served?(segment) = I18n.available_locales.include?(segment&.to_sym)

  def path_segment
    return nil if locale.blank? || locale.to_sym == I18n.default_locale

    locale.to_s
  end
end
