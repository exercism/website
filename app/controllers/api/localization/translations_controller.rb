class API::Localization::TranslationsController < API::BaseController
  before_action :use_translation

  def approve_llm_version
    Localization::Translation::ApproveLLMVersion.(@translation, current_user)

    render json: {}
  end

  private
  def use_translation
    @translation = Localization::Translation.find_by!(uuid: params[:id])
  end
end
