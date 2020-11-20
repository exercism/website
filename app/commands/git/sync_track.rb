module Git
  class SyncTrack
    include Mandate
    initialize_with :track

    def call
      lookup_head_and_current_commit
      update_track! unless track_synced_to_head?
    end

    private
    attr_reader :current_commit, :head_commit

    def lookup_head_and_current_commit
      track.git.update!

      @current_commit = track.git.send(:repo).lookup_commit(track.synced_to_git_sha)
      @head_commit = track.git.send(:repo).head_commit
    end

    def track_synced_to_head?
      current_commit.oid == head_commit.oid
    end

    def update_track!
      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      if track_config_modified?
        track.update!(
          blurb: head_config[:blurb],
          active: head_config[:active],
          title: head_config[:language],
          synced_to_git_sha: head_commit.oid
        )
      else
        track.update!(
          synced_to_git_sha: head_commit.oid
        )
      end
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
      track.git.config(commit: head_commit)
    end
  end
end
