class SerializeLocalizationOriginals
  include Mandate

  initialize_with :originals, :user

  def call
    originals_with_includes.map do |original|
      SerializeLocalizationOriginal.(original, locales[original.key])
    end
  end

  def originals_with_includes
    originals.to_active_relation # .includes(:...)
  end

  memoize
  def locales
    Localization::Translation.
      where(locale: user.translator_locales).
      where(key: originals.map(&:key)).
      group_by(&:key)
  end
end
