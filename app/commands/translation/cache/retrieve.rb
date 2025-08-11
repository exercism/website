class Translation::Cache::Retrieve
  include Mandate

  initialize_with :locale, :key

  def call
    return unless Translation.use_cache

    Translation.translations.dig(locale.to_sym, key)
  end
end
