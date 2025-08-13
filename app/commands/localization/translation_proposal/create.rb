class Localization::TranslationProposal::Create
  include Mandate

  initialize_with :translation, :user, :value

  def call
    proposal = ActiveRecord::Base.transaction do
      translation.update!(status: :proposed)
      translation.proposals.create!(
        proposer: user,
        value: value,
        modified_from_llm: true
      )
    end

    VerifyWithLLM.(proposal)
  end
end
