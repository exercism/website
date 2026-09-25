# The user menu's language switcher.
#
# A signed-in user's locale is read off their account, so the choice has to be
# saved before the redirect lands: setting only the cookie would hold for the
# prefixed URL and then be overridden everywhere else by the saved value.
#
# The cookie is set here too, and not just by the delegated click handler, so
# the choice survives signing out and still outranks a guess from
# Accept-Language. See Locale::PREF_COOKIE_NAME.
class LocaleController < ApplicationController
  def update
    return redirect_back_or_to(root_path) unless I18n.available_locales.include?(locale)

    current_user.data.update!(locale: locale.to_s)
    cookies[Locale::PREF_COOKIE_NAME] = {
      value: locale.to_s,
      path: "/",
      expires: 1.year.from_now,
      same_site: :lax
    }

    redirect_to "#{request.base_url}#{path_for_locale(locale, return_to)}"
  end

  private
  def locale = params.require(:new_locale).to_s.to_sym

  # The page the menu was opened on, not the referer: the form posts from
  # whichever page the user happened to be reading.
  def return_to
    path = params[:return_to].to_s
    path.start_with?("/") && !path.start_with?("//") ? path : root_path
  end
end
