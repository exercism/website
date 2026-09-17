# Production locales are for everyone. A work in progress locale is only
# for staff and for that locale's translators.
class Locale::MayView
  include Mandate

  initialize_with :locale, :user

  def call
    return false unless LocaleRoster.served?(locale)
    return true if LocaleRoster.production?(locale)
    return false unless user

    user.staff? || Array(user.translator_locales).map(&:to_s).include?(locale.to_s)
  end
end
