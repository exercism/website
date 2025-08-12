class Localization::OriginalsController < ApplicationController
  def index
    @originals = AssembleLocalizationOriginals.(current_user, params)[:results]
  end

  def show
    original = Localization::Original.find_by!(uuid: params[:id])

    @original = SerializeLocalizationOriginal.(original, current_user, include_proposals: true)
  end
end
