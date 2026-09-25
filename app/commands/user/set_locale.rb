class User::SetLocale
  include Mandate

  initialize_with :user, :requested_locale

  # Returns whether it saved: callers branch rather than rescue.
  def call
    return false unless I18n.available_locales.include?(locale)

    user.data.update!(locale: locale.to_s)
    true
  end

  private
  def locale = requested_locale.to_s.to_sym
end
