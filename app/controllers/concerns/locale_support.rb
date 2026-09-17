module LocaleSupport
  extend ActiveSupport::Concern

  included do
    helper_method :current_locale, :url_for_locale, :path_for_locale, :locale_scoped_route?
  end

  def current_locale = I18n.locale

  def normalize_locale(tag) = Locale::Normalize.(tag)

  # The page we're on, in another locale.
  def path_for_locale(locale, fullpath = request.fullpath) = Locale::SwapInPath.(fullpath, locale)
  def url_for_locale(locale, fullpath = request.fullpath) = "#{request.base_url}#{path_for_locale(locale, fullpath)}"

  # The locale in the URL. Only the path counts: ?locale=hu is just a query param.
  def locale_from_path = request.path_parameters[:locale]&.to_sym

  # Is this request for a route drawn inside the /:locale scope?
  # Admin, challenges, bootcamp, webhooks etc. are not, and have no /hu version.
  def locale_scoped_route? = request.route_uri_pattern.to_s.start_with?("(/:locale)", "/(:locale)")

  def html_navigation? = request.get? && request.format.html? && !request.xhr?

  def browser_locale = Locale::FromAcceptLanguage.(request.headers["Accept-Language"])

  # A work in progress locale is only for staff and its own translators.
  def may_view_locale?(locale)
    return false unless LocaleRoster.served?(locale)
    return true if LocaleRoster.production?(locale)
    return false unless user_signed_in?

    current_user.staff? || Array(current_user.translator_locales).map(&:to_s).include?(locale.to_s)
  end
end
