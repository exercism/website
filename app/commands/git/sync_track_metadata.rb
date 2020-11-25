module Git
  class SyncTrackMetadata < Sync
    include Mandate

    def initialize(track)
      super(track, track.synced_to_git_sha)
      @track = track
    end

    private
    attr_reader :track

    def sync!
      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_needs_updating?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        synced_to_git_sha: head_git_track.commit.oid
      )
    end

    def track_needs_updating?
      track_config_modified?
    end
  end
end
