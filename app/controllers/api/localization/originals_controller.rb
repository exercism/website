class API::Localization::OriginalsController < API::BaseController
  before_action :use_original, except: [:index]

  def index
    render json: AssembleLocalizationOriginals.(current_user, params)
  end

  def show
    render json: {
      original: SerializeLocalizationOriginal.(@original, current_user)
    }
  end

  def approve_llm_version
    Localization::Translation::ApproveLLMVersion.(@original, current_user)
  end

  private
  def use_original
    @original = Localization::Original.find_by!(uuid: params[:id])
  end
end
