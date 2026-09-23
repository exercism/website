module TranslationRepo
  class << self
    def metadata_path(locale, repo_name)
      raise ArgumentError, "Not a repository name: #{repo_name}" unless REPO_NAME_FORMAT.match?(repo_name.to_s)

      root / "locales" / locale.to_s / "metadata" / "#{repo_name}.json"
    end

    def metadata(locale, repo_name)
      return {} if locale.to_sym == I18n.default_locale

      catalogs = metadata_catalogs
      key = [locale.to_sym, repo_name.to_s]
      return catalogs[key] if catalogs.key?(key)

      catalogs[key] = read_metadata(locale, repo_name)
    end

    def metadata_text(locale, repo_name, unit_id)
      text = metadata(locale, repo_name)[unit_id.to_s]
      text if text.is_a?(String) && text.present?
    end

    def report_missing_metadata!(locale, repo_name, unit_id)
      message = "Missing #{locale} metadata: #{repo_name} (#{unit_id})"
      Rails.logger.warn(message)
      Sentry.capture_message(message, level: :warning, tags: { locale: locale.to_s },
        fingerprint: ["i18n-missing-metadata", locale.to_s, repo_name.to_s, unit_id.to_s])
    end

    private
    def metadata_catalogs
      version = self.version
      @metadata_catalogs = [version, {}] unless @metadata_catalogs && @metadata_catalogs.first == version
      @metadata_catalogs.last
    end

    def read_metadata(locale, repo_name)
      JSON.parse(File.read(metadata_path(locale, repo_name)))
    rescue Errno::ENOENT, Errno::ENOTDIR
      {}
    rescue JSON::ParserError => e
      Sentry.capture_exception(e, tags: { locale: locale.to_s })
      {}
    end
  end
end
