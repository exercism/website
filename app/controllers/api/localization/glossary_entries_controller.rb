class API::Localization::GlossaryEntriesController < API::BaseController
  before_action :use_glossary_entry, except: %i[index create next]

  def index
    render json: AssembleLocalizationGlossaryEntries.(current_user, params)
  end

  def next
    entry = Localization::GlossaryEntry::Search.(
      current_user,
      criteria: params[:criteria],
      status: params[:status],
      page: 1,
      per: 1,
      locale: params[:filter_locale],
      exclude_uuids: params[:exclude_uuids]
    ).first

    render json: { uuid: entry&.uuid }
  end

  def show
    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  def create
    Localization::GlossaryEntryProposal::CreateAddition.(
      params[:glossary_entry][:term],
      params[:glossary_entry][:locale],
      current_user,
      params[:glossary_entry][:translation],
      params[:glossary_entry][:llm_instructions]
    )

    render json: {}, status: :created
  end

  def destroy
    Localization::GlossaryEntryProposal::CreateDeletion.(@glossary_entry, current_user)

    render json: {}, status: :ok
  end

  private
  def use_glossary_entry
    @glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:id])
  end
end
