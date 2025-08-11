class Localization::OriginalsController < ApplicationController
  def index
    @originals = AssembleLocalizationOriginals.(current_user, params)[:results]
  end

  def show
    original = Localization::Original.find_by!(uuid: params[:id])
    locales = Localization::Translation.
      where(locale: current_user.translator_locales).
      where(key: original.key)
    @original = SerializeLocalizationOriginal.(original, locales)
  end
end
