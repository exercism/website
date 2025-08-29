class Localization::GlossaryEntryProposal::Reject
  include Mandate

  initialize_with :proposal, :user

  def call
    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :rejected,
        reviewer: user
      )
    end
  end

  delegate :glossary_entry, to: :proposal
end
