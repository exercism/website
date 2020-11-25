module Git
  class SyncTrackMetadata
    include Mandate
    initialize_with :track

    def call
      update_git_repo!
      sync! unless synced_to_head?
    end

    private
    def update_git_repo!
      git_repo.update!
    end

    def synced_to_head?
      synced_git_track.commit.oid == head_git_track.commit.oid
    end

    def sync!
      return track.update!(synced_to_git_sha: head_git_track.commit.oid) unless track_config_modified?

      # TODO: consider raising error when slug in config is different from track slug
      # TODO: validate track to prevent invalid track data
      track.update!(
        blurb: head_git_track.config[:blurb],
        active: head_git_track.config[:active],
        title: head_git_track.config[:language],
        synced_to_git_sha: head_git_track.commit.oid
      )
    end

    def track_config_modified?
      diff = head_git_track.commit.diff(synced_git_track.commit)
      diff.each_delta.any? do |delta|
        delta.old_file[:path] == head_git_track.config_filepath ||
          delta.new_file[:path] == head_git_track.config_filepath
      end
    end

    memoize
    def git_repo
      Git::Repository.new(track.slug, repo_url: track.repo_url)
    end

    memoize
    def synced_git_track
      Git::Track.new(track.slug, track.synced_to_git_sha, repo: git_repo)
    end

    memoize
    def head_git_track
      Git::Track.new(track.slug, git_repo.head_sha, repo: git_repo)
    end
  end
end
