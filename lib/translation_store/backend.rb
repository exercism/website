require 'i18n'

# The I18n backend. English and rails-i18n come from the load path as
# usual, and each locale's published backend catalog is laid over them.
#
# The whole tree is held in memory. When a pointer names a new hash, a
# fresh tree is built and then swapped in with one assignment, so a
# lookup only ever sees a complete catalog. Nothing is merged in place.
# The check is made lazily from lookups, so it works the same in Puma
# workers and in Sidekiq, with no thread to survive a fork.
class TranslationStore::Backend < I18n::Backend::Simple
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

  # English is only a safety net. A production locale falling back to it
  # means a user is looking at untranslated text, so it is reported.
  def on_fallback(original_locale, fallback_locale, key, _options)
    return unless LocaleRoster.production?(original_locale) && LocaleRoster.default?(fallback_locale)
    return unless @reported.add?([original_locale.to_sym, key.to_s])

    message = "Missing #{original_locale} translation: #{key}"
    Rails.logger.warn(message)
    Sentry.capture_message(message, level: :warning, tags: { locale: original_locale.to_s },
      fingerprint: ["i18n-missing", original_locale.to_s, key.to_s])
  end

  private
  # Costs one object comparison per lookup: the pointers are only a
  # different object once TranslationStore has re-read them.
  def refresh_if_stale!
    return unless initialized?

    pointers = TranslationStore.pointers
    return if pointers.equal?(@pointers)

    build_and_swap! unless published_hashes(pointers) == @built_from
    @pointers = pointers
  end

  def published_hashes(pointers)
    pointers.filter_map { |(locale, kind), hash| [locale, hash] if kind == :backend }.to_h
  end

  # One builder at a time. Everyone else keeps serving the current tree,
  # except at boot, when there is no tree yet and they have to wait.
  def build_and_swap!(wait: false)
    return unless wait ? @swap.lock : @swap.try_lock

    begin
      hashes = published_hashes(TranslationStore.pointers)
      catalogs = hashes.to_h { |locale, hash| [locale, catalog_for(locale, hash)] }.compact

      builder = I18n::Backend::Simple.new
      builder.load_translations
      catalogs.each { |locale, (_, tree)| builder.store_translations(locale, tree) }

      @catalogs = catalogs
      @built_from = hashes
      @reported.clear
      @translations = builder.translations
      @initialized = true
    ensure
      @swap.unlock
    end
  end

  # [hash, tree]. An artifact we can't read (the mirror writes it before
  # the pointer, so this shouldn't happen) leaves the locale as it was.
  def catalog_for(locale, hash)
    return @catalogs[locale] if @catalogs[locale]&.first == hash

    artifact = JSON.parse(File.read(TranslationStore.catalog_path(locale, :backend, hash)))
    [hash, artifact.fetch(locale.to_s)]
  rescue Errno::ENOENT, JSON::ParserError, KeyError => e
    Sentry.capture_exception(e, tags: { locale: locale.to_s })
    @catalogs[locale]
  end
end
