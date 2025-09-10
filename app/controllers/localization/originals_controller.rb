class Localization::OriginalsController < ApplicationController
  def index
    redirect_to localization_glossary_entries_url

    @originals = AssembleLocalizationOriginals.(current_user, params)[:results]
    @originals_params = params.permit(:criteria, :status, :page)
  end

  def show
    original = Localization::Original.find_by!(uuid: params[:id])

    @original = SerializeLocalizationOriginal.(original, current_user)
  end
end
