class Git::SyncToolingManager
  include Mandate

  queue_as :default

  def call
    Git::ToolingManager.new.update!
  rescue StandardError => e
    Bugsnag.notify(e)
  end
end
