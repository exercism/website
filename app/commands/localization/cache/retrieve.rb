class Localization::Cache::Retrieve
  include Mandate

  initialize_with :locale, :key

  def call
    return unless Localization.use_cache

    Localization.translations.dig(locale.to_sym, key)
  end
end
