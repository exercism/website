class API::TranslationsController < API::BaseController
  def index
    render json: AssembleTranslations.(current_user, params)
  end

  def show
    translation = Translation.find_by!(uuid: params[:id])

    render json: {
      translation: SerializeTranslation.(translation, include_proposals: true)
    }
  end
end
