module LocaleSupport
  extend ActiveSupport::Concern
  extend Mandate::Memoize

  QUERY_PARAM = :_lr # Loop-breaker for one-time redirects

  included do
    helper_method :current_locale, :default_locale, :supported_locales,
      :best_locale_from_accept_language, :path_for_locale
  end

  def supported_locales = I18n.available_locales
  def default_locale = I18n.default_locale
  def current_locale = I18n.locale

  # Map things like "pt-br" -> :"pt-BR", "es-419" -> :"es"
  def normalize_locale(code)
    return if code.blank?

    code = code.to_s.tr('_', '-')

    # Try exact match first (case-sensitive for region)
    return code.to_sym if supported_locales.map(&:to_s).include?(code)

    # Try language-only fallback (e.g., "pt-br" -> "pt")
    lang = code.split('-').first
    return lang.to_sym if supported_locales.map { _1.to_s.split('-').first }.include?(lang)

    nil
  end

  # RFC 7231 q-weighted Accept-Language parser
  memoize
  def best_locale_from_accept_language
    header = request.get_header('HTTP_ACCEPT_LANGUAGE').to_s
    return default_locale if header.blank?

    candidates = header.split(',').map do |part|
      lang, q = part.strip.split(';q=')
      qv = (q || '1').to_f
      [lang, qv]
    end

    candidates.
      sort_by { |(_, qv)| -qv }.
      map { |(lang, _)| normalize_locale(lang) }.
      compact.
      first || default_locale
  rescue StandardError
    default_locale
  end

  def html_request?
    request.format.html? && !request.xhr?
  end

  # Locale extracted from leading path segment if present and supported, excluding :en
  def locale_from_path
    locale = params[:locale]
    return nil unless locale.present?
    return nil if locale == default_locale # English lives at root

    locale
  end

  # Build a locale-scoped URL preserving the rest of the path/query
  def path_for_locale(loc, fullpath)
    uri = begin
      Addressable::URI.parse(fullpath)
    rescue StandardError
      nil
    end
    if uri
      path = uri.path
      query = uri.query
    else
      path  = fullpath
      query = nil
    end
    # Strip any existing leading locale segment before adding new one
    segments = path.to_s.sub(%r{^/}, '').split('/') # Remove leading slash and split into segments

    # If we have a locale, remove it.
    path_locale = normalize_locale(segments[0])
    segments.shift if path_locale.present?
    path = "/#{segments.join('/')}"

    new_path = "/#{loc}#{path}".gsub(%r{/{2,}}, "/")
    new_path += "?#{query}" if query.present?

    # Add one-time loop-breaker for server-side redirects only
    new_path += (query.present? ? "&" : "?") + "#{QUERY_PARAM}=1" unless new_path.include?("#{QUERY_PARAM}=")
    new_path
  end
end
