class SyncTrackJob < ApplicationJob
  queue_as :default

  def perform(track)
    Git::SyncTrack.(track)
  end
end
