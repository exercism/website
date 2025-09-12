class Localization::Original::TranslateToAllLocales
  include Mandate

  initialize_with :original

  def call
    # Some strings don't need translating, so we skip them.
    return unless original.should_translate?

    locales.each do |locale|
      next if existing_locales.include?(locale.to_sym)

      Localization::Original::Translate.defer(original, locale)
    end
  end

  def locales = (I18n.available_locales + I18n.wip_locales)

  memoize
  def existing_locales = original.translations.pluck(:locale).map(&:to_sym)
end
