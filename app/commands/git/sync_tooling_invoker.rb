class Git::SyncToolingInvoker
  include Mandate

  queue_as :default

  def call
    Git::ToolingInvoker.new.update!
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
