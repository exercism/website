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

  # TODO(iHiD): OPEN. What a first-time signed-out visitor sees. This is
  # the input for it. The leading idea is a one-line banner in their browser's
  # language. It must never be a modal that opens for English speakers, and
  # never an edge redirect, because pages are CDN-cached by URL. nil (no
  # header, as crawlers send) must mean no banner and no redirect.
  def browser_locale = Locale::FromAcceptLanguage.(request.headers["Accept-Language"])

  def may_view_locale?(locale) = Locale::MayView.(locale, current_user)
end
