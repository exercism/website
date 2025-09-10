class Localization::OriginalsController < ApplicationController
  before_action :ensure_translator_locale
  def index
    redirect_to localization_glossary_entries_url

    @originals = AssembleLocalizationOriginals.(current_user, params)[:results]
    @originals_params = params.permit(:criteria, :status, :page)
  end

  def show
    original = Localization::Original.find_by!(uuid: params[:id])

    @original = SerializeLocalizationOriginal.(original, current_user)
  end

  private
  def ensure_translator_locale
    return if current_user&.translator_locales.present?

    redirect_to new_localization_translator_path
  end
end
