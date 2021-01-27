module Git
  class Sync
    include Mandate

    initialize_with :track, :synced_to_git_sha

    def call
      raise NotImplementedError
    end

    def filepath_in_diff?(filepath)
      diff.each_delta.any? do |delta|
        [delta.old_file[:path], delta.new_file[:path]].include?(filepath)
      end
    end

    memoize
    def git_repo
      Git::Repository.new(repo_url: track.repo_url)
    end

    memoize
    def head_git_track
      Git::Track.new(git_repo.head_sha, repo: git_repo)
    end

    memoize
    def synced_to_head?
      current_git_track.commit.oid == head_git_track.commit.oid
    end

    memoize
    def track_config_modified?
      filepath_in_diff?(head_git_track.config_filepath)
    end

    memoize
    def concept_exercises_config
      config[:exercises][:concept]
    end

    memoize
    def practice_exercises_config
      config[:exercises][:practice]
    end

    memoize
    def concepts_config
      config[:concepts] || []
    end

    private
    memoize
    delegate :config, to: :head_git_track

    memoize
    def current_git_track
      Git::Track.new(synced_to_git_sha, repo: git_repo)
    end

    memoize
    def diff
      head_git_track.commit.diff(current_git_track.commit)
    end
  end
end
