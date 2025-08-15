class Localization::Translation::ApproveLLMVersion
  include Mandate

  initialize_with :translation, :user

  def call
    ActiveRecord::Base.transaction do
      translation.proposals.create!(
        proposer: user,
        modified_from_llm: false,
        value: translation.value
      )
      translation.update!(status: :proposed)
    end
  end
end
