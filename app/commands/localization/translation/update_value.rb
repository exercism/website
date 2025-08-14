class Localization::Translation::UpdateValue
  include Mandate

  initialize_with :key, :locale, :value

  def call
    translation.update!(
      value: value,
      status: :unchecked
    )
    broadcast!(translation)
  end

  private
  memoize
  def translation
    Localization::Translation.find_by!(key: key, locale: locale)
  end

  def broadcast!(translation)
    LocalizationTranslationChannel.broadcast!(translation)
  end
end
