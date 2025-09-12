class Localization::GlossaryEntryProposal
  class UpdateValue
    include Mandate

    initialize_with :proposal, :user, :term, :translation, :llm_instructions

    def call
      guard!

      proposal.update!(term:, translation:, llm_instructions:)

      VerifyWithLLM.defer(proposal)
    end

    private
    def guard!
      return if user.may_manage_translation_proposals?

      raise "You need to have at least 10 rep to create glossary entries"
    end
  end
end
