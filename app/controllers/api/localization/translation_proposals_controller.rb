class API::Localization::TranslationProposalsController < API::BaseController
  before_action :use_translation
  before_action :use_proposal, except: [:create]

  def create
    Localization::TranslationProposal::Create.(@translation, current_user, params[:value])

    render json: {
      translation: SerializeLocalizationTranslation.(@translation)

    }, status: :created
  end

  def approve
    Localization::TranslationProposal::Approve.(@translation, current_user)

    render json: {
      translation: SerializeLocalizationTranslation.(@translation)
    }
  end

  def reject
    Localization::TranslationProposal::Reject.(@translation, current_user)

    render json: {
      translation: SerializeLocalizationTranslation.(@translation)
    }
  end

  def update
    if @proposal.proposer == current_user
      Localization::TranslationProposal::UpdateValue.(@proposal, current_user, params[:value])
    else
      Localization::TranslationProposal::Reject.(@proposal, current_user)
      Localization::TranslationProposal::Create.(@translation, current_user, params[:value])
    end

    render json: {
      translation: SerializeLocalizationTranslation.(@translation)
    }
  end

  private
  def use_translation
    @translation = Localization::Translation.find_by!(uuid: params[:translation_id])
  end

  def use_proposal
    @proposal = @translation.proposals.find_by!(uuid: params[:id])
  end
end
