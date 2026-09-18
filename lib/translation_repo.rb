require 'json'
require 'digest'

module TranslationRepo
  URL = "https://github.com/exercism/i18n.git".freeze
  BRANCH = "main".freeze
  OID_FORMAT = /\A[0-9a-f]{40}\z/

  CHECK_INTERVAL_SECONDS = 10

  class << self
    def root = Pathname.new(Exercism.config.efs_repositories_mount_point) / "i18n"

    def version
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      return @version if @version_read_at && now - @version_read_at < CHECK_INTERVAL_SECONDS

      @version_read_at = now
      @version = read_head
    end

    def cache_key(locale = I18n.locale)
      return locale.to_s if locale.to_sym == I18n.default_locale

      [locale, version].compact.join("-")
    end

    def backend_catalog_path(locale) = root / "locales" / locale.to_s / "website" / "backend.json"
    def frontend_catalog_path(locale) = root / "locales" / locale.to_s / "website" / "frontend.json"

    def frontend_catalog_url(locale)
      return if locale.to_sym == I18n.default_locale

      hash = frontend_catalog_hash(locale) or return
      "/i18n/#{locale}/frontend-#{hash}.json"
    end

    def frontend_catalog_hash(locale)
      hashes = frontend_catalog_hashes
      return hashes[locale.to_sym] if hashes.key?(locale.to_sym)

      hashes[locale.to_sym] = catalog_hash(File.binread(frontend_catalog_path(locale)))
    rescue Errno::ENOENT
      hashes[locale.to_sym] = nil
    end

    def catalog_hash(bytes) = Digest::SHA256.hexdigest(bytes)[0, 12]

    def content_path(locale, blob_id, extension)
      raise ArgumentError, "Not a git blob id: #{blob_id}" unless OID_FORMAT.match?(blob_id)

      root / "locales" / locale.to_s / "content" / blob_id[0, 2] / blob_id[2, 2] / "#{blob_id[4..]}#{extension}"
    end

    def content(locale, blob_id, extension)
      File.read(content_path(locale, blob_id, extension))
    rescue Errno::ENOENT
      nil
    end

    def report_missing_content!(locale, blob_id, path)
      return unless I18n.available_locales.include?(locale.to_sym)

      message = "Missing #{locale} content: #{path} (#{blob_id})"
      Rails.logger.warn(message)
      Sentry.capture_message(message, level: :warning, tags: { locale: locale.to_s },
        fingerprint: ["i18n-missing-content", locale.to_s, blob_id])
    end

    def expire!
      @version_read_at = nil
      @frontend_catalog_hashes = nil
    end

    private
    def frontend_catalog_hashes
      version = self.version
      @frontend_catalog_hashes = [version, {}] unless @frontend_catalog_hashes && @frontend_catalog_hashes.first == version
      @frontend_catalog_hashes.last
    end

    def read_head
      head = File.read(root / ".git" / "HEAD").strip
      sha = head.start_with?("ref: ") ? resolve_ref(head.delete_prefix("ref: ")) : head
      sha if OID_FORMAT.match?(sha.to_s)
    rescue Errno::ENOENT, Errno::ENOTDIR
      nil
    end

    def resolve_ref(ref)
      File.read(root / ".git" / ref).strip
    rescue Errno::ENOENT
      File.foreach(root / ".git" / "packed-refs") do |line|
        sha, name = line.split(" ", 2)
        return sha if name&.strip == ref
      end
      nil
    end
  end
end

require_relative 'translation_repo/backend'
