module Git
  class SyncExercise
    include Mandate
    initialize_with :exercise

    def call
      lookup_head_and_current_commit
      update_exercise! unless exercise_synced_to_head?
    end

    private
    attr_reader :current_commit, :head_commit

    def lookup_head_and_current_commit
      exercise.git.update!

      @current_commit = exercise.git.lookup_commit(exercise.synced_to_git_sha)
      @head_commit = exercise.git.head_commit
    end

    def exercise_synced_to_head?
      current_commit.oid == head_commit.oid
    end

    def update_exercise!
      send("update_#{exercise.git_type}_exercise!")
      # # TODO: validate exercise to prevent invalid exercise data
    end

    def update_concept_exercise!
      return exercise.update!(synced_to_git_sha: head_commit.oid) unless exercise_modified?

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_commit.oid,
        synced_to_git_sha: head_commit.oid
      )
    end

    def update_practice_exercise!
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
      return false if current_commit.oid == head_commit.oid

      # TODO
      false
    end

    def track_config_modified?
      return false if current_commit.oid == head_commit.oid

      diff.each_delta.any? do |delta|
        delta.old_file[:path] == exercise.track.git.config_filepath ||
          delta.new_file[:path] == exercise.track.git.config_filepath
      end
    end

    memoize
    def config_exercise
      # TODO: determine what to do when the exercise could not be found
      head_config = exercise.track.git.config(commit: head_commit)
      head_config[:exercises][:concept].find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def diff
      head_commit.diff(current_commit)
    end
  end
end
