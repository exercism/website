# One URL is one language, and the URL always wins over a stored preference.
module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  # TODO(iHiD): OPEN. Whether a signed-in user on a naked URL is sent to
  # their own language. Flip this to turn it on. The alternative is to
  # never redirect, and offer the language in a banner instead.
  REDIRECT_SIGNED_IN_USERS = false

  private
  def switch_locale!(&)
    locale = locale_from_path || I18n.default_locale
    return render_404 unless may_view_locale?(locale)

    I18n.with_locale(locale, &)
  end

  def redirect_to_user_locale!
    return unless REDIRECT_SIGNED_IN_USERS
    return unless user_signed_in? && html_navigation?
    return if locale_from_path.present?   # The URL wins.
    return unless locale_scoped_route?    # /challenges/48in24 has no /hu version.

    locale = user_locale
    return if locale.nil? || LocaleRoster.default?(locale)
    return unless may_view_locale?(locale)

    # Which language a URL leads to here depends on the visitor, so this
    # must never be cached, by browsers or the CDN.
    response.headers['Cache-Control'] = 'private, no-store'
    redirect_to path_for_locale(locale), status: :found
  end

  # TODO(iHiD): OPEN. What "the user's locale" is. Today it is the single
  # user_data.locale column. Jiki's model is an explicit choice plus the
  # stored Accept-Language, with the explicit choice winning.
  def user_locale = normalize_locale(current_user&.locale)
end
