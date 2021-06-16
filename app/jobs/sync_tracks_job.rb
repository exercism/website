# The goal of this job is to re-sync all tracks to guard against one of the
# GitHub webhook calls failing, which would result in unsynced tracks
class SyncTracksJob < ApplicationJob
  queue_as :dribble

  def perform
    ::Track.find_each do |track|
      Git::SyncTrack.(track, force_sync: true)
    end
  end
end
