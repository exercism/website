module Git
  class SyncTrackMetadata
    include Mandate
    initialize_with :track

    def call
      fetch_git_data!
      sync! unless synced_to_head?
    end

    private
    attr_reader :synced_git_track, :head_git_track

    def fetch_git_data!
      git_repo = Git::Repository.new(track.slug, repo_url: track.repo_url)
      git_repo.update!

      @synced_git_track = Git::Track.new(track.slug, track.synced_to_git_sha, repo: git_repo)
      @head_git_track = Git::Track.new(track.slug, git_repo.head_sha, repo: git_repo)
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
  end
end
