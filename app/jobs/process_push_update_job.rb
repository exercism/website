class ProcessPushUpdateJob < ApplicationJob
  queue_as :default

  def perform(_track)
    # TODO: enable this once we're out of the monorepo
    # Git::SyncTrack.(track)

    # TODO: remove this this once we're out of the monorepo
    Track.all.each do |track|
      Git::SyncTrack.(track)
    rescue StandardError => e
      Rails.logger.error "Error syncing Track #{track.slug}: #{e}"
    end
  end
end
