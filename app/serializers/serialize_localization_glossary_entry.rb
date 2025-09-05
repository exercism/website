class SerializeLocalizationGlossaryEntry
  include Mandate

  initialize_with :glossary_entry, :user, proposals: nil

  def call
    {
      uuid: glossary_entry.uuid,
      locale: glossary_entry.locale,
      term: glossary_entry.term,
      translation: glossary_entry.translation,
      status: glossary_entry.status.to_s,
      llm_instructions: glossary_entry.llm_instructions,
      proposals: proposals.map do |proposal|
        {
          uuid: proposal.uuid,
          type: proposal.type.to_s,
          status: proposal.status.to_s,
          term: proposal.term,
          translation: proposal.translation,
          llm_instructions: proposal.llm_instructions,
          proposer_id: proposal.proposer&.id,
          reviewer_id: proposal.reviewer&.id
        }
      end
    }
  end

  memoize
  def proposals
    Array.new(
      @proposals || @glossary_entry.proposals.where.not(status: :rejected)
    )
  end
end
