class API::Localization::GlossaryEntryProposalsController < API::BaseController
  before_action :use_glossary_entry
  before_action :use_proposal, except: [:create]

  def create
    Localization::GlossaryEntryProposal::Create.(@glossary_entry, current_user, params[:value])

    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }, status: :created
  end

  def approve
    Localization::GlossaryEntryProposal::Approve.(@glossary_entry, current_user)

    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  def reject
    Localization::GlossaryEntryProposal::Reject.(@glossary_entry, current_user)

    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  def update
    if @proposal.proposer == current_user
      Localization::GlossaryEntryProposal::UpdateValue.(@proposal, current_user, params[:value])
    else
      Localization::GlossaryEntryProposal::Reject.(@proposal, current_user)
      Localization::GlossaryEntryProposal::Create.(@glossary_entry, current_user, params[:value])
    end

    render json: {
      glossary_entry: SerializeLocalizationGlossaryEntry.(@glossary_entry, current_user)
    }
  end

  private
  def use_glossary_entry
    @glossary_entry = Localization::GlossaryEntry.find_by!(uuid: params[:glossary_entry_id])
  end

  def use_proposal
    @proposal = @glossary_entry.proposals.find_by!(uuid: params[:id])
  end
end
