class API::Localization::GlossaryEntriesController < API::BaseController
  before_action :use_glossary_entry, except: %i[index create]

  def index
    render json: AssembleLocalizationGlossaryEntries.(current_user, params)
  end

  def show
    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  def create
    Localization::GlossaryEntry::Create.(
      params[:glossary_entry][:locale],
      params[:glossary_entry][:term],
      params[:glossary_entry][:translation],
      params[:glossary_entry][:llm_instructions]
    )

    render json: {}, status: :created
  end

  private
  def use_glossary_entry
    @glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:id])
  end
end
