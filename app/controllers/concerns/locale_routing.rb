module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  # TODO(iHiD): OPEN. Whether a signed-in user on a naked URL is redirected to their own language.
  REDIRECT_SIGNED_IN_USERS = false

  private
  def switch_locale!(&)
    locale = locale_from_path || I18n.default_locale
    return render_404 unless may_view_locale?(locale)

    response.headers['X-Robots-Tag'] = 'noindex' unless LocaleRoster.production?(locale)

    I18n.with_locale(locale, &)
  end

  def redirect_to_user_locale!
    return unless REDIRECT_SIGNED_IN_USERS
    return unless user_signed_in? && html_navigation?
    return if locale_from_path.present?
    return unless locale_scoped_route?

    locale = user_locale
    return if locale.nil? || LocaleRoster.default?(locale)
    return unless may_view_locale?(locale)

    # The redirect depends on the visitor, so it must never be cached.
    response.headers['Cache-Control'] = 'private, no-store'
    redirect_to path_for_locale(locale), status: :found
  end

  # TODO(iHiD): OPEN. What "the user's locale" is.
  # TODO(iHiD): OPEN. Where a user picks their language.
  def user_locale = normalize_locale(current_user&.locale)
end
