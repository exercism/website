module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  private
  def switch_locale!(&)
    personal_locale = locale_from_path ? nil : non_default_user_locale
    locale = locale_from_path || personal_locale || I18n.default_locale

    response.headers['Cache-Control'] = 'private, no-store' if personal_locale

    I18n.with_locale(locale, &)
  end

  def non_default_user_locale
    locale = user_locale
    locale unless locale.blank? || locale.to_sym == I18n.default_locale
  end

  # TODO(iHiD): OPEN. What "the user's locale" is.
  # TODO(iHiD): OPEN. Where a user picks their language.
  def user_locale = normalize_locale(current_user&.locale)
end
