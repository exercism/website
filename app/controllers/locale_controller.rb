class LocaleController < ApplicationController
  def update
    # Normalize and validate
    locale = normalize_locale(params[:locale])

    if I18n.available_locales.include?(locale.to_sym)
      # Logged-in → save to DB
      current_user&.update!(locale: locale)
    else
      locale = default_locale
    end

    # Anonymous → JS will handle localStorage

    # Everyone gets redirected.
    redirect_to path_for_locale(locale, params[:return_to] || root_path)
  end
end
