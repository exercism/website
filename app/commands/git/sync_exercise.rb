module Git
  class SyncExercise
    include Mandate
    initialize_with :exercise

    def call
      update_git_repo!
      sync! unless synced_to_head?
    end

    private
    def update_git_repo!
      git_repo.update!
    end

    def synced_to_head?
      synced_git_exercise.commit.oid == head_git_exercise.commit.oid
    end

    def sync!
      # # TODO: validate exercise to prevent invalid exercise data
      send("sync_#{exercise.git_type}_exercise!")
    end

    def sync_concept_exercise!
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless exercise_modified?

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid
      )
    end

    def sync_practice_exercise!
      # TODO
    end

    def exercise_modified?
      config_exercise_modified? || exercise_files_modified?
    end

    def config_exercise_modified?
      return false unless track_config_modified?

      config_exercise[:slug] != exercise.slug ||
        config_exercise[:name] != exercise.title ||
        !!config_exercise[:deprecated] != exercise.deprecated
    end

    def exercise_files_modified?
      # TODO
      false
    end

    def track_config_modified?
      diff = head_git_exercise.commit.diff(synced_git_exercise.commit)
      diff.each_delta.any? do |delta|
        delta.old_file[:path] == head_git_track.config_filepath ||
          delta.new_file[:path] == head_git_track.config_filepath
      end
    end

    memoize
    def config_exercise
      # TODO: determine what to do when the exercise could not be found
      head_git_track.config[:exercises][:concept].find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def git_repo
      Git::Repository.new(exercise.track.slug, repo_url: exercise.track.repo_url)
    end

    memoize
    def synced_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, exercise.synced_to_git_sha, repo: git_repo)
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end

    memoize
    def head_git_track
      Git::Track.new(exercise.track.slug, git_repo.head_sha, repo: git_repo)
    end
  end
end
