module LocaleSupport
  extend ActiveSupport::Concern

  QUERY_PARAM = :_lr # Loop-breaker for one-time redirects

  included do
    helper_method :current_locale, :default_locale, :supported_locales
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
  def locale_from_path
    locale = params[:locale]
    return nil unless locale.present?
    return nil if locale == default_locale # English lives at root

    locale
  end
end
