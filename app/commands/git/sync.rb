module Git
  class Sync
    include Mandate

    initialize_with :track, :synced_to_git_sha

    def call
      raise NotImplementedError
    end

    def update_git_repo!
      git_repo.update!
    end

    def filepath_in_diff?(filepath)
      diff.each_delta.any? do |delta|
        [delta.old_file[:path], delta.new_file[:path]].include?(filepath)
      end
    end

    memoize
    def git_repo
      Git::Repository.new(track.slug, repo_url: track.repo_url)
    end

    memoize
    def head_git_track
      Git::Track.new(track.slug, git_repo.head_sha, repo: git_repo)
    end

    memoize
    def synced_git_track
      Git::Track.new(track.slug, synced_to_git_sha, repo: git_repo)
    end

    memoize
    def synced_to_head?
      synced_git_track.commit.oid == head_git_track.commit.oid
    end

    memoize
    def track_config_modified?
      filepath_in_diff?(head_git_track.config_filepath)
    end

    memoize
    def diff
      head_git_track.commit.diff(synced_git_track.commit)
    end

    memoize
    def config_concept_exercises
      config[:exercises][:concept]
    end

    memoize
    def config_practice_exercises
      config[:exercises][:practice]
    end

    memoize
    def config_concepts
      config[:concepts]
    end

    memoize
    delegate :config, to: :head_git_track
  end
end
