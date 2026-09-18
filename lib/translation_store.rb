require 'json'

# Reads the tree that exercism/i18n publishes, mirrored onto EFS.
module TranslationStore
  CATALOG_KINDS = %i[backend frontend].freeze
  PUBLISHED_PREFIX = "i18n".freeze
  HASH_FORMAT = /\A[0-9a-f]{12}\z/
  BLOB_ID_FORMAT = /\A[0-9a-f]{40}\z/

  CHECK_INTERVAL_SECONDS = 10

  class << self
    def root = Pathname.new(Exercism.config.efs_i18n_mount_point)

    def current_hash(locale, kind) = pointers[[locale.to_sym, kind.to_sym]]

    def pointers
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      return @pointers if @pointers && @pointers_read_at && now - @pointers_read_at < CHECK_INTERVAL_SECONDS

      @pointers_read_at = now
      @pointers = read_pointers
    end

    def frontend_catalog_url(locale)
      hash = current_hash(locale, :frontend) or return

      "#{Rails.application.config.asset_host}/#{PUBLISHED_PREFIX}/website/#{locale}/frontend-#{hash}.json"
    end

    def cache_key(locale = I18n.locale)
      [locale, *CATALOG_KINDS.map { |kind| current_hash(locale, kind) }].compact.join("-")
    end

    def catalog_path(locale, kind, hash) = root / "website" / locale.to_s / "#{kind}-#{hash}.json"

    def content_path(locale, blob_id, extension)
      raise ArgumentError, "Not a git blob id: #{blob_id}" unless BLOB_ID_FORMAT.match?(blob_id)

      root / "content" / locale.to_s / blob_id[0, 2] / blob_id[2, 2] / "#{blob_id[4..]}#{extension}"
    end

    def content(locale, blob_id, extension)
      File.read(content_path(locale, blob_id, extension))
    rescue Errno::ENOENT
      nil
    end

    def report_missing_content!(locale, blob_id, path)
      return unless LocaleRoster.production?(locale)

      message = "Missing #{locale} content: #{path} (#{blob_id})"
      Rails.logger.warn(message)
      Sentry.capture_message(message, level: :warning, tags: { locale: locale.to_s },
        fingerprint: ["i18n-missing-content", locale.to_s, blob_id])
    end

    def expire! = @pointers_read_at = nil

    private
    def read_pointers
      (LocaleRoster.known - [LocaleRoster.default]).product(CATALOG_KINDS).filter_map do |locale, kind|
        hash = read_pointer(locale, kind)
        [[locale, kind], hash] if hash
      end.to_h.freeze
    end

    def read_pointer(locale, kind)
      hash = JSON.parse(File.read(root / "website" / locale.to_s / "#{kind}.current.json"))["hash"]
      hash if HASH_FORMAT.match?(hash.to_s)
    rescue Errno::ENOENT, JSON::ParserError
      nil
    end
  end
end

require_relative 'translation_store/backend'
