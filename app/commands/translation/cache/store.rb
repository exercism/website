class Translation::Cache::Store
  include Mandate

  initialize_with :locale, :key, :value

  def call
    return unless Translation.use_cache

    Translation.translations[locale.to_sym] ||= {}
    Translation.translations[locale.to_sym][key] = value
  end
end
