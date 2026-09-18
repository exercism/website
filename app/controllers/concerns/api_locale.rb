module APILocale
  extend ActiveSupport::Concern
  include LocaleSupport

  HEADER = 'X-Exercism-Locale'.freeze

  included do
    # Runs after authentication, so a token-authenticated user's own
    # locale is visible to it.
    skip_around_action :switch_locale!
    around_action :switch_api_locale!
    after_action :set_locale_vary_header
  end

  private
  def switch_api_locale!(&) = I18n.with_locale(api_locale, &)

  def api_locale
    [request_locale, user_locale].compact.find { |locale| may_view_locale?(locale) } || I18n.default_locale
  end

  def request_locale = normalize_locale(request.headers[HEADER])

  def set_locale_vary_header
    response.headers["Vary"] = [response.headers["Vary"], HEADER].compact.uniq.join(", ")
  end
end
