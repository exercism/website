module LocaleSupport
  extend ActiveSupport::Concern

  QUERY_PARAM = :_lr # Loop-breaker for one-time redirects

  included do
    helper_method :current_locale, :default_locale, :supported_locales,
      :url_for_locale
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

  def html_request?
    request.format.html? && !request.xhr?
  end

  # Locale extracted from leading path segment if present and supported, excluding :en
  def specified_locale
    locale = params[:locale]
    return nil unless locale.present?
    return nil if locale == default_locale # English lives at root

    locale.to_sym
  end

  def locale_from_path
    return unless params[:locale]

    locale = request.path.to_s.sub(%r{^/}, '').split('/').first

    return unless supported_locales.map(&:to_s).include?(locale)

    locale.to_sym
  end

  # Build a locale-scoped URL preserving the rest of the path/query
  def url_for_locale(loc, fullpath, path_only: false, add_loop_breaker_query_param: true)
    uri = begin
      Addressable::URI.parse(fullpath)
    rescue StandardError
      nil
    end
    path = uri&.path || fullpath

    # Break into segments, ignore blanks (so /foo/ -> ["foo"])
    segments = path.split("/").reject(&:empty?)

    # Drop existing locale if present
    segments.shift if segments.first && normalize_locale(segments.first).present?

    # Skip prefix if using default locale
    loc = "" if loc == default_locale

    # Build path string (no leading slash yet)
    new_path = ([loc] + segments).reject(&:empty?).join("/")

    # Parse query params
    query_string = uri&.query.to_s

    if add_loop_breaker_query_param
      query_hash = Rack::Utils.parse_nested_query(query_string)
      qp = LocaleSupport::QUERY_PARAM.to_s
      query_hash[qp] ||= "1" # only add if not already present
      query_string = Rack::Utils.build_query(query_hash)
    end

    if path_only
      ["/#{new_path.presence}", query_string.presence].compact.join("?")
    elsif new_path.empty?
      [request.base_url, query_string.presence].compact.join("?")
    else
      ["#{request.base_url}/#{new_path}", query_string.presence].compact.join("?")
    end
  end
end
