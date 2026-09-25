class SettingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[reset_account destroy_account]

  def api_cli; end

  def communication_preferences; end

  def insiders; end

  def donations
    @payments = current_user.payments.includes(:subscription).order(id: :desc)
  end

  # The user menu's language switcher posts here rather than to the settings
  # page's API endpoint: that one skips CSRF and answers with JSON, and a
  # server-rendered form wants the redirect.
  def update_locale
    return redirect_back_or_to(root_path) unless User::SetLocale.(current_user, locale)

    # Set here as well as by the click handler, so the choice survives signing
    # out and still outranks a guess from Accept-Language.
    cookies[Locale::PREF_COOKIE_NAME] = {
      value: locale.to_s,
      path: "/",
      expires: 1.year.from_now,
      same_site: :lax
    }

    redirect_to "#{request.base_url}#{path_for_locale(locale, return_to)}"
  end

  def disconnect_discord
    current_user.update!(discord_uid: nil)
    redirect_to action: :integrations
  end

  def reset_account
    # This takes seconds for a large account, and nothing in the response
    # depends on it having finished, so run it in the background.
    User::ResetAccount.defer(current_user) if params[:handle] == current_user.handle

    render json: {
      links: {
        home: Exercism::Routes.root_url
      }
    }
  end

  def destroy_account
    User::DestroyAccount.(current_user) if params[:handle] == current_user.handle

    render json: {
      links: {
        home: Exercism::Routes.root_url
      }
    }
  end

  private
  def locale = params[:new_locale].to_s.to_sym

  # The page the menu was opened on, not the referer.
  def return_to
    path = params[:return_to].to_s
    path.start_with?("/") && !path.start_with?("//") ? path : root_path
  end
end
