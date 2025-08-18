module LocaleSupport
  extend ActiveSupport::Concern

  QUERY_PARAM = :_lr # Loop-breaker for one-time redirects

  included do
    helper_method :current_locale, :default_locale, :supported_locales,
      :url_for_locale, :url_for_locale
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

    locale
  end

  def locale_from_path
    return unless params[:locale]

    locale = request.path.to_s.sub(%r{^/}, '').split('/').first

    return unless supported_locales.map(&:to_s).include?(locale)

    locale
  end

  # Build a locale-scoped URL preserving the rest of the path/query
  def url_for_locale(loc, fullpath, path_only: false, add_loop_breaker_query_param: true)
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

    loc = "" if loc == default_locale # Don't prefix with "en" for English

    new_path = "/#{loc}#{path}".gsub(%r{/{2,}}, "/")
    new_path += "?#{query}" if query.present?

    # Add one-time loop-breaker for server-side redirects only
    if add_loop_breaker_query_param && !new_path.include?("#{LocaleSupport::QUERY_PARAM}=")
      new_path += (query.present? ? "&" : "?") + "#{LocaleSupport::QUERY_PARAM}=1"
    end
    new_path = new_path.chomp('/') # Strip trailing slash

    path_only ? new_path : "#{request.protocol}#{request.hostname}#{new_path}"
  end
end
