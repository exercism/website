class SyncTrackJob < ApplicationJob
  queue_as :default

  def perform(track, force_sync: false)
    Git::SyncTrack.(track, force_sync:)
  end
end
