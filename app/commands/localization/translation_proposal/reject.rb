class Localization::TranslationProposal::Reject
  include Mandate

  initialize_with :proposal, :user

  def call
    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :rejected,
        reviewer: user
      )
      translation.update!(status: :unchecked) unless translation.proposals.pending.exists?
    end
  end

  delegate :translation, to: :proposal
end
