class Localization::GlossaryEntryProposal::Reject
  include Mandate

  initialize_with :glossary_entry, :user

  def call
    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :rejected,
        reviewer: user
      )
    end
  end

  memoize
  def proposal
    glossary_entry.proposals.pending.first
  end
end
