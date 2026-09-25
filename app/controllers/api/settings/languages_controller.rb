class API::Settings::LanguagesController < API::BaseController
  def update
    return render_400(:invalid_locale) unless User::SetLocale.(current_user, locale)

    render json: {}, status: :ok
  end

  private
  def locale = params.require(:language).permit(:locale)[:locale]
end
