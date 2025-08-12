class SerializeLocalizationOriginal
  include Mandate

  initialize_with :original, :translations, include_proposals: false

  def call
    {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      sample_interpolations: original.sample_interpolations
    }.tap do |data|
      data[:translations] = translations.filter_map do |translation|
        next if translation.locale == "en"

        {
          uuid: translation.uuid,
          locale: translation.locale,
          value: translation.value,
          status: translation.status
        }
      end

      if include_proposals
        data[:proposals] = proposals.map do |proposal|
          {
            uuid: proposal.uuid,
            proposer: proposal.proposer&.uuid,
            reviewer: proposal.reviewer&.uuid,
            status: proposal.status,
            value: proposal.value
          }
        end
      end
    end
  end

  memoize
  def proposals
    original.proposals.where.not(status: :rejected)
  end
end
