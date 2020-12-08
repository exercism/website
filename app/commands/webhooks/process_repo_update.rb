module Webhooks
  class ProcessRepoUpdate
    include Mandate

    initialize_with :ref, :track_slug

    def call
      return unless pushed_to_master?

      # TODO: enable this once we're out of the monorepo
      # Git::SyncTrack.(track)

      # TODO: remove this this once we're out of the monorepo
      Track.all.each do |track|
        Git::SyncTrack.(track)
      rescue StandardError => e
        Rails.logger.error "Error syncing Track #{track.slug}: #{e}"
      end
    end

    def track
      Track.find_by(slug: track_slug)
    end

    def pushed_to_master?
      ref == MASTER_REF
    end

    MASTER_REF = "refs/heads/master".freeze
    private_constant :MASTER_REF
  end
end
