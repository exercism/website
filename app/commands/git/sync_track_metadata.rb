module Git
  class SyncTrackMetadata
    include Mandate

    def initialize(track)
      @track = track
      @git_track = Git::Track.new(track.slug, repo_url: track.repo_url)
    end

    def call
      lookup_head_and_current_commit
      update_track! unless track_synced_to_head?
    end

    private
    attr_reader :track, :git_track, :current_commit, :head_commit

    def lookup_head_and_current_commit
      git_track.update!

      @current_commit = git_track.lookup_commit(track.synced_to_git_sha)
      @head_commit = git_track.head_commit
    end

    def track_synced_to_head?
      current_commit.oid == head_commit.oid
    end

    def update_track!
      return track.update!(synced_to_git_sha: head_commit.oid) unless track_config_modified?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_config[:blurb],
        active: head_config[:active],
        title: head_config[:language],
        synced_to_git_sha: head_commit.oid
      )
    end

    def track_config_modified?
      diff = head_commit.diff(current_commit)
      diff.each_delta.any? do |delta|
        delta.old_file[:path] == track.git.config_filepath ||
          delta.new_file[:path] == track.git.config_filepath
      end
    end

    memoize
    def head_config
      git_track.config(commit: head_commit)
    end
  end
end
