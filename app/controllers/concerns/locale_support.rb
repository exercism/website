module LocaleSupport
  extend ActiveSupport::Concern

  included do
    helper_method :current_locale, :url_for_locale, :path_for_locale, :locale_scoped_route?,
      :english_exercise_docs?, :exercise_docs_locale
  end

  def current_locale = I18n.locale

  def english_exercise_docs? = false
  def exercise_docs_locale = english_exercise_docs? ? I18n.default_locale : I18n.locale

  def normalize_locale(tag) = Locale::Normalize.(tag)

  def path_for_locale(locale, fullpath = request.fullpath) = Locale::SwapInPath.(fullpath, locale)
  def url_for_locale(locale, fullpath = request.fullpath) = "#{request.base_url}#{path_for_locale(locale, fullpath)}"

  def locale_from_path = request.path_parameters[:locale]&.to_sym

  def locale_scoped_route? = request.route_uri_pattern.to_s.start_with?("(/:locale)", "/(:locale)")

  def html_navigation? = request.get? && request.format.html? && !request.xhr?

  # TODO(iHiD): OPEN. What a first-time signed-out visitor sees.
  def browser_locale = Locale::FromAcceptLanguage.(request.headers["Accept-Language"])
end
