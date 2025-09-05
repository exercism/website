class Localization::Text::Translate
  include Mandate

  initialize_with :type, :text, :about, :locale

  def call
    Localization::Translation.find_by!(key: key, locale: locale)&.value.presence
  rescue ActiveRecord::RecordNotFound
    # Add it - which will kick off translations
    Localization::Text::AddToLocalization.(type, text, about, priority_locale: locale)
    nil
  end

  memoize
  def key = Localization::Text::GenerateKey.(text)
end
