class Localization::GlossaryEntryProposal
  class CreateModification
    include Mandate

    initialize_with :glossary_entry, :user, :translation

    def call
      ActiveRecord::Base.transaction do
        glossary_entry.update!(status: :proposed)
        Localization::GlossaryEntryProposal.create!(
          type: :modification,
          glossary_entry: glossary_entry,
          proposer: user,
          translation: translation
        )
      end.tap do |proposal| # rubocop:disable Style/MultilineBlockChain
        VerifyWithLLM.defer(proposal)
      end
    end
  end
end
