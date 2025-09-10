class Localization::GlossaryEntryProposal::Reject
  include Mandate

  initialize_with :proposal, :user

  def call
    guard!

    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :rejected,
        reviewer: user
      )

      # Set glossary_entry status to unchecked if no pending proposals remain (for modifications only)
      if proposal.type == :modification && proposal.glossary_entry
        glossary_entry = proposal.glossary_entry
        glossary_entry.update!(status: :unchecked) unless glossary_entry.proposals.pending.exists?
      end
    end
  end

  private
  def guard!
    return if user.may_manage_translation_proposals?

    raise "You need to have at least 20 rep to reject glossary entries"
  end
end
