class SerializeLocalizationOriginal
  include Mandate

  initialize_with :original, :user

  def call
    {
      uuid: original.uuid,
      key: original.key,
      value: original.value,
      context: original.data[:context],
      translations: translations.filter_map do |translation|
        next if translation.locale == "en"

        SerializeLocalizationTranslation.(translation, proposals: proposals[translation.id])
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
