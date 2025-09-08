class Localization::Text::AddToLocalization
  include Mandate

  initialize_with :type, :text, :about, priority_locale: nil, should_translate: true

  def call
    original.tap do
      trigger_priority_locale!
      Localization::Original::TranslateToAllLocales.defer(original)
    end
  end

  private
  # We sometimes have a priority locale where there is a user waiting
  # for this translation to be generated. In those cases, let's make
  # sure that we do this first! We do this inline to get it to the front
  # of the queue.
  def trigger_priority_locale!
    return unless original.should_translate?
    return unless priority_locale.present?

    Localization::Original::Translate.(original, priority_locale)
  rescue StandardError
    # We catch errors (as this be duplicated in the all
    #  locales below in sidekiq anyway)
  end

  memoize
  def original
    Localization::Original::Create.(type, key, text, about, should_translate)
  rescue ActiveRecord::RecordNotUnique
    Localization::Original.find_by!(key: key)
  end

  memoize
  def existing_locales = original.translations.pluck(:locale).map(&:to_sym)

  memoize
  def key = Localization::Text::GenerateKey.(text)
end
