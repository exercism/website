class Localization::GlossaryEntryProposal
  class CreateModification
    include Mandate

    initialize_with :glossary_entry, :user, :translation, :llm_instructions

    def call
      ActiveRecord::Base.transaction do
        Localization::GlossaryEntryProposal.create!(
          type: :modification,
          glossary_entry: glossary_entry,
          proposer: user,
          translation: translation,
          llm_instructions: llm_instructions
        )
      end.tap do |proposal| # rubocop:disable Style/MultilineBlockChain
        VerifyWithLLM.defer(proposal)
      end
    end
  end
end
