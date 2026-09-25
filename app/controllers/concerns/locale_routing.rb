module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  # The public, cacheable pages a first-time visitor is moved between: sections
  # matched by prefix, single pages matched exactly. This is the set that opts
  # into cache_public_action!, and it is deliberately narrower than the set of
  # locale-prefixed routes. The stateful flows (auth, settings, unsubscribe)
  # carry per-user state through the URL, and bouncing someone mid-flow risks
  # breaking the flow for no benefit.
  PUBLIC_SECTIONS = LocaleConfig::PUBLIC_SECTIONS
  PUBLIC_PAGES = LocaleConfig::PUBLIC_PAGES

  included do
    before_action :redirect_to_preferred_locale!
    before_action :redirect_signed_in_to_unprefixed!
  end

  private
  # A signed-in user always reads the site in their own locale, on unprefixed
  # URLs, whatever locale is in the path. Everyone else gets the path's locale
  # and links that keep it.
  def switch_locale!(&)
    if locale_user
      personal_locale = non_default_user_locale
      Current.url_locale = nil
      response.headers['Cache-Control'] = 'private, no-store' if personal_locale

      I18n.with_locale(personal_locale || I18n.default_locale, &)
    else
      Current.url_locale = locale_from_path
      I18n.with_locale(locale_from_path || I18n.default_locale, &)
    end
  end

  def non_default_user_locale
    locale = user_locale
    locale unless locale.blank? || locale.to_sym == I18n.default_locale
  end

  def user_locale = normalize_locale(locale_user&.locale)

  # Devise's own actions authenticate from params, and must do so themselves.
  def locale_user = devise_controller? ? warden.user(:user) : current_user

  # Move an anonymous visitor to the locale they want, the first time they
  # arrive. 302 rather than 301, and uncacheable: which locale a URL serves is
  # a property of the visitor, not of the URL.
  def redirect_to_preferred_locale!
    return unless locale_redirect_candidate?

    target = preferred_locale
    return if target.nil? || target == (locale_from_path || I18n.default_locale)

    response.headers["Cache-Control"] = "private, no-store"
    response.headers["Vary"] = "Accept-Language, Cookie"
    redirect_to path_for_locale(target), status: :found
  end

  # A signed-in user's locale comes from their settings, so a locale in the
  # path only makes the URL differ from everyone else's. Page navigations are
  # moved to the unprefixed URL. Other requests to a prefixed path (forms,
  # frames, fetches such as the tooltip endpoints stored in old rendered
  # markdown) are served where they are, in the user's locale.
  def redirect_signed_in_to_unprefixed!
    return unless locale_user
    return unless locale_from_path
    return unless request.get? || request.head?
    return unless request.format.html?
    return if request.xhr?
    return if request.headers["Turbo-Frame"].present?
    return if devise_controller?

    response.headers["Cache-Control"] = "private, no-store"
    redirect_to path_for_locale(I18n.default_locale), status: :found
  end

  # Precedence is explicit choice > explicit URL > browser guess.
  #
  # The preference cookie wins outright: it exists only once the visitor has
  # used the switcher or the banner, so it is the one unambiguously deliberate
  # signal, and it has to survive following a link into another language.
  # Otherwise a locale already in the path wins, which is what keeps every
  # non-default URL shareable and independently crawlable. Only then do we
  # guess from Accept-Language, and that is the only clause that moves anyone.
  #
  # No supported language anywhere means no redirect. That covers unsupported
  # languages and, critically, clients sending no Accept-Language at all:
  # crawlers among them. Were those to resolve to English, every prefixed URL
  # would bounce to its naked form on every crawl and no locale but English
  # would ever be indexed.
  def preferred_locale
    normalize_locale(cookies[Locale::PREF_COOKIE_NAME]) || locale_from_path || browser_locale
  end

  def locale_redirect_candidate?
    return false unless request.get? || request.head?
    return false unless request.format.html?
    return false if request.xhr?
    return false if request.headers["Turbo-Frame"].present?
    return false if devise_controller?
    return false if user_signed_in?
    return false if cookies.signed[:_exercism_user_id].present?

    public_locale_path?
  end

  def public_locale_path?
    path = Locale::SwapInPath.(request.path, I18n.default_locale)
    return true if PUBLIC_PAGES.include?(path)

    PUBLIC_SECTIONS.any? { |section| path == section || path.start_with?("#{section}/") }
  end
end
