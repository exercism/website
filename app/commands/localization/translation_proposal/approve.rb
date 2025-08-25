class Localization::TranslationProposal::Approve
  include Mandate

  initialize_with :proposal, :user

  def call
    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :approved,
        reviewer: user
      )
      translation.update!(
        status: :checked,
        value: proposal.value
      )
    end
  end

  delegate :translation, to: :proposal
end
