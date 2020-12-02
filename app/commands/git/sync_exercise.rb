module Git
  class SyncExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    private
    attr_reader :exercise

    def sync!
      # TODO: validate exercise to prevent invalid exercise data
      send("sync_#{exercise.git_type}_exercise!")
    end

    def sync_concept_exercise!
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless concept_exercise_needs_updating?

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid,
        taught_concepts: find_concepts(config_exercise[:concepts]),
        prerequisites: find_concepts(config_exercise[:prerequisites])
      )
    end

    def sync_practice_exercise!
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless practice_exercise_needs_updating?

      exercise.update!(
        slug: config_exercise[:slug],
        title: config_exercise[:name],
        deprecated: config_exercise[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid,
        prerequisites: find_concepts(config_exercise[:prerequisites])
      )
    end

    def concept_exercise_needs_updating?
      config_concept_exercise_modified? || exercise_files_modified?
    end

    def config_concept_exercise_modified?
      return false unless track_config_modified?

      config_exercise[:slug] != exercise.slug ||
        config_exercise[:name] != exercise.title ||
        !!config_exercise[:deprecated] != exercise.deprecated ||
        config_exercise[:concepts].sort != exercise.taught_concepts.map(&:slug).sort ||
        config_exercise[:prerequisites].sort != exercise.prerequisites.map(&:slug).sort
    end

    def practice_exercise_needs_updating?
      config_practice_exercise_modified? || exercise_files_modified?
    end

    def config_practice_exercise_modified?
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
      config_exercises = exercise.concept_exercise? ? config_concept_exercises : config_practice_exercises
      config_exercises.find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
