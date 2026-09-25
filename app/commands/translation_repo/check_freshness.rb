class TranslationRepo::CheckFreshness
  include Mandate

  MAX_LAG = 30.minutes

  # Reports an error once the site has served the same commit for longer than
  # MAX_LAG while exercism/i18n's main has moved on. The clock runs from when a
  # check first saw that commit behind main, and keeps running while main moves,
  # so frequent pushes cannot hide a sync that has stopped working.
  def call
    return if served == latest

    behind_since = Rails.cache.fetch("translation-repo/behind-since/#{served}", expires_in: 7.days) { Time.current.to_i }
    lag = Time.current.to_i - behind_since
    return if lag < MAX_LAG

    report!(lag)
  end

  private
  memoize
  def served
    TranslationRepo.expire!
    TranslationRepo.version
  end

  memoize
  def latest
    output, status = Open3.capture2e("git", "ls-remote", TranslationRepo::URL, "refs/heads/#{TranslationRepo::BRANCH}")
    raise "git ls-remote failed: #{output}" unless status.success?

    output.split("\t").first
  end

  def report!(lag)
    minutes = lag / 60
    message = "Translations have been behind exercism/i18n for #{minutes} minutes: serving #{served || 'nothing'}, main is #{latest}"
    Rails.logger.error(message)
    Sentry.capture_message(message, level: :error, fingerprint: ["translations-stale"])
  end
end
