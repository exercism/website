class ProcessPushUpdateJob < ApplicationJob
  queue_as :default

  def perform(_track)
    Git::SyncTrack.(track)
  end
end
