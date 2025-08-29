class API::Localization::GlossaryEntriesController < API::BaseController
  before_action :use_glossary_entry, except: [:index]

  def index
    render json: AssembleLocalizationGlossaryEntries.(current_user, params)
  end

  def show
    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  private
  def use_glossary_entry
    @glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:id])
  end
end
