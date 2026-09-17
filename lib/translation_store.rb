require 'json'

# Read access to the translations exercism/i18n publishes. Something
# outside this repo mirrors the published `i18n/` tree onto EFS, so under
# the root we expect exactly what exercism/i18n's publish.mjs builds:
#
#   website/<locale>/<kind>.current.json   the pointer: { "hash": "..." }
#   website/<locale>/<kind>-<hash>.json    immutable catalog artifacts
#   content/<locale>/<ab>/<cd>/<rest>.<ext>  one file per English git blob id
#
# English is never in here. It ships with the website.
module TranslationStore
  CATALOG_KINDS = %i[backend frontend].freeze
  PUBLISHED_PREFIX = "i18n".freeze
  HASH_FORMAT = /\A[0-9a-f]{12}\z/
  BLOB_ID_FORMAT = /\A[0-9a-f]{40}\z/

  # How often a process looks at the pointer files again.
  CHECK_INTERVAL = 10 # seconds

  class << self
    attr_writer :root

    def root = Pathname.new(@root || ENV["EXERCISM_I18N_DIR"].presence || default_root)

    # The hash the pointer currently names, or nil if nothing is published.
    # Cached for CHECK_INTERVAL so callers can ask on every request.
    def current_hash(locale, kind) = pointers[[locale.to_sym, kind.to_sym]]

    # { [locale, kind] => hash }. A new object each time the files are re-read.
    def pointers
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      return @pointers if @pointers && @pointers_read_at && now - @pointers_read_at < CHECK_INTERVAL

      @pointers_read_at = now
      @pointers = read_pointers
    end

    # Where the browser fetches a locale's frontend catalog from: the same
    # key exercism/i18n uploads it under, on the assets host. Immutable,
    # as the hash is in the URL. nil for English or when nothing is published.
    def frontend_catalog_url(locale)
      hash = current_hash(locale, :frontend) or return

      "#{Rails.application.config.asset_host}/#{PUBLISHED_PREFIX}/website/#{locale}/frontend-#{hash}.json"
    end

    def catalog_path(locale, kind, hash) = root / "website" / locale.to_s / "#{kind}-#{hash}.json"

    def content_path(locale, blob_id, extension)
      raise ArgumentError, "Not a git blob id: #{blob_id}" unless BLOB_ID_FORMAT.match?(blob_id)

      root / "content" / locale.to_s / blob_id[0, 2] / blob_id[2, 2] / "#{blob_id[4..]}#{extension}"
    end

    def expire! = @pointers_read_at = nil

    private
    def default_root
      return Rails.root / "test" / "tmp" / "i18n" if Rails.env.test?
      return Rails.root / "tmp" / "i18n" if Rails.env.development?

      # TODO: Give exercism-config an efs_i18n_mount_point and use it here.
      File.join(File.dirname(Exercism.config.efs_repositories_mount_point), "i18n")
    end

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
