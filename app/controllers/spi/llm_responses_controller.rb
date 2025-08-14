module SPI
  class LLMResponsesController < BaseController
    def localization_verify_llm_proposal
      proposal = Localization::TranslationProposal.find_by!(uuid: params[:proposal_uuid])
      feedback = JSON.parse(params[:resp], symbolize_names: true)
      proposal.update!(llm_feedback: feedback)

      return unless feedback[:result] == "spam"

      Localization::TranslationProposal::Reject.(proposal, User.find(User::SYSTEM_USER_ID))
      # TODO: Alert iHiD
    end

    def localization_translated
      original = Localization::Original.find_by!(uuid: params[:original_uuid])
      resp = JSON.parse(params[:resp], symbolize_names: true)
      Localization::Translation::UpdateValue.(original.key, params[:locale], resp[:value])
    end
  end
end
