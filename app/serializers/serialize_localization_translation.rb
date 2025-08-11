class SerializeLocalizationTranslation
  include Mandate

  initialize_with :translation, proposals: nil

  def call
    {
      uuid: translation.uuid,
      locale: translation.locale,
      value: translation.value,
      status: translation.status,
      proposals: proposals.map do |proposal|
        {
          uuid: proposal.uuid,
          status: proposal.status,
          value: proposal.value,
          modified_from_llm: proposal.modified_from_llm?,
          proposer_id: proposal.proposer&.user_id,
          reviewer_id: proposal.reviewer&.user_id,
          llm_feedback: proposal.llm_feedback
        }
      end
    }
  end

  memoize
  def proposals
    Array.new(
      @proposals || @translation.proposals.where.not(status: :rejected)
    )
  end
end
