module Webhooks
  class RepoUpdatesController < BaseController
    def create
      return unless pushed_to_master?

      # TODO: enable this once we're out of the monorepo
      # sync_track

      # TODO: remove this this once we're out of the monorepo
      sync_tracks

      render json: {}, status: :ok
    end

    private
    def sync_track
      Git::SyncTrack.(track)
    end

    def sync_tracks
      Track.all.each do |track|
        Git::SyncTrack.(track)
      rescue StandardError => e
        Rails.logger.error "Error syncing Track #{track.slug}: #{e}"
      end
    end

    def track
      Track.find_by(slug: track_slug)
    end

    def track_slug
      params[:repo][:name]
    end

    def pushed_to_master?
      params[:ref] == MASTER_REF
    end

    MASTER_REF = "refs/heads/master".freeze
    private_constant :MASTER_REF
  end
end
