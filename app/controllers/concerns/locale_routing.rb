module LocaleRouting
  extend ActiveSupport::Concern
  extend Mandate::Memoize
  include LocaleSupport

  included do
    # Order matters:
    before_action :maybe_redirect_user_to_correct_locale!
    before_action :maybe_redirect_en_to_naked!
    around_action :switch_locale!
  end

  def maybe_redirect_user_to_correct_locale!
    return unless user_signed_in?       # Only signed in users.
    return unless html_request?         # Only HTML requests.
    return unless request.get?          # Only GETs
    return if locale_from_path.present? # Already on /xx/ path
    return if params[LocaleSupport::QUERY_PARAM].present? # guard against loops (localStorage or link adds this once)

    user_locale = current_user.locale
    return unless user_locale.present?

    user_locale = normalize_locale(user_locale)
    return if user_locale.to_s.starts_with?("en")

    response.headers['Cache-Control'] = 'no-store'
    redirect_to url_for_locale(user_locale, request.fullpath), allow_other_host: false, status: :found
  end

  def maybe_redirect_en_to_naked!
    return unless html_request?             # Only HTML requests.
    return unless request.get?              # Only GETs
    return unless locale_from_path == :en

    redirect_to request.fullpath.sub(%r{^/en}, ''), allow_other_host: false, status: :found
  end

  def switch_locale!(&action)
    locale = specified_locale || default_locale
    I18n.with_locale(locale, &action)
  end

  # Use this as a before)action in places where we don't want a
  # locale-specific version of a controller
  # e.g. in admin or bootcamp or challenges
  def redirect_to_english!
    return unless html_request?             # Only HTML requests.
    return unless request.get?              # Only GETs
    return unless specified_locale.present?
    return if specified_locale == default_locale

    response.headers['Cache-Control'] = 'no-store'
    redirect_to url_for_locale(:en, request.fullpath), allow_other_host: false, status: :found
  end
end
