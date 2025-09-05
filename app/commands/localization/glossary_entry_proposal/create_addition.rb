class Localization::GlossaryEntryProposal
  class CreateAddition
    include Mandate

    initialize_with :term, :locale, :user, :translation, :llm_instructions

    def call
      ActiveRecord::Base.transaction do
        Localization::GlossaryEntryProposal.create!(
          type: :addition,
          proposer: user,
          term: term,
          locale: locale,
          translation: translation,
          llm_instructions: llm_instructions
        )
      end.tap do |proposal| # rubocop:disable Style/MultilineBlockChain
        VerifyWithLLM.defer(proposal)
      end
    end
  end
end
