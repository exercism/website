class Localization::GlossaryEntryProposal
  class UpdateValue
    include Mandate

    initialize_with :proposal, :user, :term, :translation, :llm_instructions

    def call
      proposal.update!(term:, translation:, llm_instructions:)

      VerifyWithLLM.defer(proposal)
    end
  end
end
