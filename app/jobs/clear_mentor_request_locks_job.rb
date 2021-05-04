class ClearMentorRequestLocksJob < ApplicationJob
  queue_as :cron

  def perform
    Mentor::RequestLock.expired.delete_all
  end
end
