class Localization::Content::Retrieve
  include Mandate

  initialize_with :type, :text, :locale

  def call
    # Exit early if someone is actively requesting the English
    # version so that we don't go through extra lookups etc.
    return text if locale == :en

    # Look this up here, so we don't do the work of creating the context etc.
    Localization::Translation.find_by(key: key, locale: locale)&.value.presence
  end

  private
  def key = Localization::Text::GenerateKey.(text)
end
