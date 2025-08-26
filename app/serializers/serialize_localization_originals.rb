class SerializeLocalizationOriginals
  include Mandate

  initialize_with :originals, :user

  def call
    originals_with_includes.map do |original|
      {
        uuid: original.uuid,
        key: original.key,
        title: original.title,
        pretty_type: original.type.to_s.titleize,
        value: original.value,
        translations: (translations[original.key] || []).filter_map do |translation|
          next if translation.locale == "en"

          {
            uuid: translation.uuid,
            locale: translation.locale,
            status: translation.status
          }
        end
      }
    end
  end

  def originals_with_includes
    originals.to_active_relation.includes(:about)
  end

  memoize
  def translations
    Localization::Translation.
      where(locale: user.translator_locales).
      where(key: originals.map(&:key)).
      group_by(&:key)
  end
end
