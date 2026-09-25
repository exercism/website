class TranslationRepo::SyncOnBoot
  include Mandate

  TIMEOUT_SECONDS = 120
  RETRY_INTERVAL_SECONDS = 2

  initialize_with timeout_seconds: TIMEOUT_SECONDS, retry_interval_seconds: RETRY_INTERVAL_SECONDS

  def call
    deadline = now + timeout_seconds

    loop do
      return synced! if sync
      return fell_back! if checkout_present?
      return gave_up! if now + retry_interval_seconds > deadline

      sleep(retry_interval_seconds)
    end
  end

  private
  def sync
    TranslationRepo::Sync.()
  rescue StandardError => e
    @error = e
    false
  end

  def checkout_present?
    TranslationRepo.expire!
    TranslationRepo.version.present?
  end

  def synced!
    TranslationRepo.expire!
    Rails.logger.info("Translations synced on boot: #{TranslationRepo.version}")
    true
  end

  def fell_back!
    if @error
      report_failure!("Translations sync on boot failed; booting on the existing checkout", level: :warning)
    else
      Rails.logger.info("Translations sync on boot skipped: another process is syncing and a checkout is present")
    end

    true
  end

  def gave_up!
    report_failure!("Translations sync on boot gave up after #{timeout_seconds}s with no checkout present", level: :error)

    false
  end

  def report_failure!(message, level:)
    full_message = [message, @error&.message].compact.join(": ")
    Rails.logger.public_send(level == :error ? :error : :warn, full_message)

    if @error
      Sentry.capture_exception(@error, level:, fingerprint: ["translations-sync-on-boot"])
    else
      Sentry.capture_message(full_message, level:, fingerprint: ["translations-sync-on-boot"])
    end
  end

  def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
end
