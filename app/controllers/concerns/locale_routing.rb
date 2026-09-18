module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  private
  def switch_locale!(&)
    personal_locale = locale_from_path ? nil : viewable_user_locale
    locale = locale_from_path || personal_locale || I18n.default_locale
    return render_404 unless may_view_locale?(locale)

    response.headers['Cache-Control'] = 'private, no-store' if personal_locale
    response.headers['X-Robots-Tag'] = 'noindex' unless LocaleRoster.production?(locale)

    I18n.with_locale(locale, &)
  end

  def viewable_user_locale
    locale = user_locale
    return if locale.blank? || LocaleRoster.default?(locale)

    locale if may_view_locale?(locale)
  end

  # TODO(iHiD): OPEN. What "the user's locale" is.
  # TODO(iHiD): OPEN. Where a user picks their language.
  def user_locale = normalize_locale(current_user&.locale)
end
