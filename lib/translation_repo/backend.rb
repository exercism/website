require 'i18n'

class TranslationRepo::Backend < I18n::Backend::Simple
  include I18n::Backend::Pluralization

  REQUESTED_KEY = :translation_repo_requested_key

  def initialize
    super
    @swap = Mutex.new
    @catalogs = {}
    @reported = Concurrent::Set.new
  end

  def reload! = build_and_swap!(wait: true)

  def translate(locale, key, options = I18n::EMPTY_HASH)
    return super if Thread.current[REQUESTED_KEY]

    Thread.current[REQUESTED_KEY] = [locale, key]
    begin
      super
    ensure
      Thread.current[REQUESTED_KEY] = nil
    end
  end

  def translations(do_init: false)
    refresh_if_stale! if do_init
    super
  end

  protected
  def init_translations = build_and_swap!(wait: true)

  def lookup(locale, key, scope = [], options = I18n::EMPTY_HASH)
    refresh_if_stale!
    super.tap { |entry| report_missing!(locale, key) if entry.nil? && Thread.current[REQUESTED_KEY] == [locale, key] }
  end

  private
  def report_missing!(locale, key)
    return unless @reported.add?([locale.to_sym, key.to_s])

    message = "Missing #{locale} translation: #{key}"
    Rails.logger.warn(message)
    Sentry.capture_message(message, level: :warning, tags: { locale: locale.to_s },
      fingerprint: ["i18n-missing", locale.to_s, key.to_s])
  end

  def refresh_if_stale!
    return unless initialized?

    version = TranslationRepo.version
    build_and_swap! unless version == @built_from
  end

  def build_and_swap!(wait: false)
    return unless wait ? @swap.lock : @swap.try_lock

    begin
      version = TranslationRepo.version
      catalogs = locales.index_with { |locale| catalog_for(locale, version) }.compact

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

  def locales = Rails.application.config.i18n.available_locales - [I18n.default_locale]

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
