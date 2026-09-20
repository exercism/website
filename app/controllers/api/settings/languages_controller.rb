class API::Settings::LanguagesController < API::BaseController
  def update
    return render_400(:invalid_locale) unless I18n.available_locales.include?(locale)

    current_user.data.update!(locale: locale.to_s)
    render json: {}, status: :ok
  end

  private
  def locale = params.require(:language).permit(:locale)[:locale].to_s.to_sym
end
