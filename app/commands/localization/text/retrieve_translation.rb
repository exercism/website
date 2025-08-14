class Localization::Text::RetrieveTranslation
  include Mandate

  initialize_with :text, :locale

  def call
    Localization::Translation.find_by!(key: key, locale: locale)&.value.presence
  end

  memoize
  def key = Localization::Text::GenerateKey.(text)
end
