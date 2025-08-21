class Localization::Text::AddToLocalization
  include Mandate

  initialize_with :type, :text, :about_id, priority_locale: nil

  def call
    original.tap do
      trigger_priority_locale!
      queue_all_locales!
    end
  end

  private
  # We sometimes have a priority locale where there is a user waiting
  # for this translation to be generated. In those cases, let's make
  # sure that we do this first! We do this inline to get it to the front
  # of the queue.
  def trigger_priority_locale!
    return unless priority_locale.present?

    Localization::Original::Translate.(original, priority_locale)
    # rescue StandardError
    # We catch errors (as this be duplicated in the all
    #  locales below in sidekiq anyway)
  end

  # Then we trigger all locales to be translated.
  # We don't want to redo any that already exist.
  def queue_all_locales!
    (I18n.available_locales + I18n.wip_locales).each do |locale|
      next if existing_locales.include?(locale.to_sym)

      Localization::Original::Translate.defer(original, locale)
    end
  end

  memoize
  def original
    Localization::Original::Create.(type, key, text, about_id)
  rescue ActiveRecord::RecordNotUnique
    Localization::Original.find_by!(key: key)
  end

  memoize
  def existing_locales = original.translations.pluck(:locale).map(&:to_sym)

  memoize
  def key = Localization::Text::GenerateKey.(text)
end
