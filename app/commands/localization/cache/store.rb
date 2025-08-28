class Localization::Cache::Store
  include Mandate

  initialize_with :locale, :key, :value

  def call
    return unless Localization.use_cache

    Localization.translations[locale.to_sym] ||= {}
    Localization.translations[locale.to_sym][key] = value
  end
end
