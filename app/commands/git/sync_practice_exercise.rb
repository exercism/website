module Git
  class SyncPracticeExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless exercise_needs_updating?

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid,
        prerequisites: find_concepts(config_exercise[:prerequisites])
      )
    end

    private
    attr_reader :exercise

    def exercise_needs_updating?
      return false if synced_to_head?

      config_exercise_modified? || exercise_files_modified?
    end

    def config_exercise_modified?
      return false unless track_config_modified?

      config_exercise[:slug] != exercise.slug ||
        # TODO: enable the line underneath when (if?) practice exercises have names
        # config_exercise[:name] != exercise.title ||
        !!config_exercise[:deprecated] != exercise.deprecated ||
        config_exercise[:prerequisites].sort != exercise.prerequisites.map(&:slug).sort
    end

    def exercise_files_modified?
      head_git_exercise.non_ignored_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_concepts(slugs)
      slugs.map do |slug|
        config_concept = config_concepts.find { |e| e[:slug] == slug }
        ::Track::Concept.find_by!(uuid: config_concept[:uuid])
      end
    end

    memoize
    def config_exercise
      # TODO: determine what to do when the exercise could not be found
      config_practice_exercises.find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
