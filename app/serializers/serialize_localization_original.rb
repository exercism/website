class SerializeLocalizationOriginal
  include Mandate

  initialize_with :original, :user

  def call
    {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      sample_interpolations: original.sample_interpolations,
      translations: translations.filter_map do |translation|
        next if translation.locale == "en"

        {
          uuid: translation.uuid,
          locale: translation.locale,
          value: translation.value,
          status: translation.status,
          proposals: (proposals[translation.id] || []).map do |proposal|
            {
              uuid: proposal.uuid,
              status: proposal.status,
              value: proposal.value,
              proposer: proposal.proposer&.user_id,
              reviewer: proposal.reviewer&.user_id
            }
          end
        }
      end
    }
  end

  memoize
  def translations
    original.translations.
      where(locale: user.translator_locales)
  end

  memoize
  def proposals
    Localization::TranslationProposal.
      where.not(status: :rejected).
      where(translation: translations).
      group_by(&:translation_id)
  end
end
