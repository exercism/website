module SPI
  class LLMResponsesController < BaseController
    def verify_llm_proposal
      proposal = Localization::TranslationProposal.find_by!(uuid: params[:proposal_uuid])
      feedback = JSON.parse(params[:content], symbolize_names: true)
      proposal.update!(llm_feedback: feedback)

      return unless feedback[:result] == "spam"

      Localization::TranslationProposal::Reject.(proposal, User.find(User::SYSTEM_USER_ID))
      # TODO: Alert iHiD
    end
  end
end
