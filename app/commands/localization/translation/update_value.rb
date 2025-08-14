class Localization::Translation::UpdateValue
  include Mandate

  initialize_with :key, :locale, :value

  def call
    # Don't override things that might have already been done
    return unless translation.value.blank? && %i[generating unchecked].include?(translation.status)

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
