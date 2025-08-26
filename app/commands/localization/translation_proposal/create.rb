class Localization::TranslationProposal
  class Create
    include Mandate

    initialize_with :translation, :user, :value

    def call
      ActiveRecord::Base.transaction do
        translation.update!(status: :proposed)
        translation.proposals.create!(
          proposer: user,
          value: value,
          modified_from_llm: true
        )
      end.tap do |proposal| # rubocop:disable Style/MultilineBlockChain
        VerifyWithLLM.(proposal)
      end
    end
  end
end
