class ExercismI18nBackend
  include I18n::Backend::Flatten
  include I18n::Backend::Base
  include I18n::Backend::Memoize
  include I18n::Backend::Cache
  include I18n::Backend::Fallbacks

  def translate(locale, key, options = {})
    value = Localization::Translation.lookup(locale, key, options.merge(use_cache: true))
    return value if value.present?

    throw(:exception, I18n::MissingTranslationData.new(locale, key, options))
  end

  def available_locales
    %i[en hu nl de pt pt-BR]
    # Localization::Translation.distinct.pluck(:locale).map(&:to_sym)
  end
end

I18n.backend = I18n::Backend::Chain.new(
  ExercismI18nBackend.new,
  I18n.backend
)

# TODO
# Rails.application.config.i18n.available_locales = %i[en hu nl de pt pt-BR]
I18n.define_singleton_method(:wip_locales, -> { %i[es] })
Rails.application.config.i18n.default_locale = :en
