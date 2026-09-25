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
  # The header sets the language. It only sets the prefix of the URLs in the
  # response for an anonymous visitor, because a signed-in user's URLs are
  # never prefixed. A token-authenticated user may be signed in after this
  # runs, which the Warden hook in config/initializers/url_defaults.rb covers.
  def switch_api_locale!(&)
    Current.url_locale = user_signed_in? ? nil : request_locale
    I18n.with_locale(api_locale, &)
  end

  def api_locale
    [request_locale, user_locale].compact.first || I18n.default_locale
  end

  def request_locale = normalize_locale(request.headers[HEADER])

  def set_locale_vary_header
    response.headers["Vary"] = [response.headers["Vary"], HEADER].compact.uniq.join(", ")
  end
end
