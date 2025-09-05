class Localization::GlossaryEntryProposal::Approve
  include Mandate

  initialize_with :glossary_entry, :user

  def call
    ActiveRecord::Base.transaction do
      proposal.update!(
        status: :approved,
        reviewer: user
      )
      handle_glossary_update!
    end
  end

  private
  def handle_glossary_update!
    send("handle_#{proposal.type.to_s.camelize(:lower)}!")
  end

  def handle_addition!
    raise "Glossary entry already exists" if Localization::GlossaryEntry.exists?(locale: proposal.locale, term: proposal.term)

    Localization::GlossaryEntry.create!(
      locale: proposal.locale,
      term: proposal.term,
      translation: proposal.translation,
      llm_instructions: proposal.llm_instructions
    )
  end

  def handle_modification!
    raise "No glossary entry to modify" if glossary_entry.nil?

    glossary_entry.update!(
      translation: proposal.translation,
      llm_instructions: proposal.llm_instructions
    )
  end

  def handle_deletion!
    raise "No glossary entry to delete" if glossary_entry.nil?

    # Retrieve this before destroying else we have a race
    glossary_entry = proposal.glossary_entry

    # Disassociate before deletion to avoid FK issues
    proposal.update!(glossary_entry: nil)
    glossary_entry.destroy!
  end

  memoize
  def proposal
    glossary_entry.proposals.pending.first
  end
end
