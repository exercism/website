require 'i18n'

class TranslationRepo::Backend < I18n::Backend::Simple
  include I18n::Backend::Pluralization
  include I18n::Backend::Fallbacks

  def initialize
    super
    @swap = Mutex.new
    @catalogs = {}
    @reported = Concurrent::Set.new
  end

  def reload! = build_and_swap!(wait: true)

  def translations(do_init: false)
    refresh_if_stale! if do_init
    super
  end

  protected
  def init_translations = build_and_swap!(wait: true)

  def lookup(locale, key, scope = [], options = EMPTY_HASH)
    refresh_if_stale!
    super
  end

  def on_fallback(original_locale, fallback_locale, key, _options)
    return unless LocaleRoster.production?(original_locale) && LocaleRoster.default?(fallback_locale)
    return unless @reported.add?([original_locale.to_sym, key.to_s])

    message = "Missing #{original_locale} translation: #{key}"
    Rails.logger.warn(message)
    Sentry.capture_message(message, level: :warning, tags: { locale: original_locale.to_s },
      fingerprint: ["i18n-missing", original_locale.to_s, key.to_s])
  end

  private
  def refresh_if_stale!
    return unless initialized?

    version = TranslationRepo.version
    build_and_swap! unless version == @built_from
  end

  def build_and_swap!(wait: false)
    return unless wait ? @swap.lock : @swap.try_lock

    begin
      version = TranslationRepo.version
      catalogs = locales.to_h { |locale| [locale, catalog_for(locale, version)] }.compact

      builder = I18n::Backend::Simple.new
      builder.load_translations
      catalogs.each { |locale, (_, tree)| builder.store_translations(locale, tree) }

      @catalogs = catalogs
      @built_from = version
      @reported.clear
      @translations = builder.translations
      @initialized = true
    ensure
      @swap.unlock
    end
  end

  def locales = LocaleRoster.known - [LocaleRoster.default]

  def catalog_for(locale, version)
    return @catalogs[locale] if version && @catalogs[locale]&.first == version

    [version, JSON.parse(File.read(TranslationRepo.backend_catalog_path(locale)))]
  rescue Errno::ENOENT
    nil
  rescue JSON::ParserError => e
    Sentry.capture_exception(e, tags: { locale: locale.to_s })
    @catalogs[locale]
  end
end
