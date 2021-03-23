module Git
  class SyncConceptExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      return exercise.update!(synced_to_git_sha: head_git_exercise.synced_git_sha) unless exercise_needs_updating?

      exercise.update!(
        slug: exercise_config[:slug],
        # TODO: Remove the || ... once we have configlet checking things properly.
        title: exercise_config[:name].presence || exercise_config[:slug].titleize,
        deprecated: exercise_config[:deprecated] || false,
        git_sha: head_git_exercise.synced_git_sha,
        synced_to_git_sha: head_git_exercise.synced_git_sha,
        taught_concepts: find_concepts(exercise_config[:concepts]),
        prerequisites: find_concepts(exercise_config[:prerequisites])
      )

      SyncAuthors.(exercise)
      SyncContributors.(exercise)
    end

    private
    attr_reader :exercise

    def exercise_needs_updating?
      exercise_config_modified? || exercise_files_modified?
    end

    def exercise_config_modified?
      return false unless track_config_modified?

      exercise_config[:slug] != exercise.slug ||
        exercise_config[:name] != exercise.title ||
        !!exercise_config[:deprecated] != exercise.deprecated ||
        exercise_config[:concepts].to_a.sort != exercise.taught_concepts.map(&:slug).sort ||
        exercise_config[:prerequisites].to_a.sort != exercise.prerequisites.map(&:slug).sort
    end

    def exercise_files_modified?
      head_git_exercise.tooling_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_concepts(slugs)
      slugs.to_a.map do |slug|
        concept_config = concepts_config.find { |e| e[:slug] == slug }
        ::Track::Concept.find_by!(uuid: concept_config[:uuid])
      rescue StandardError
        # TODO: Remove this rescue when configlet works
      end.compact
    end

    memoize
    def author_usernames_config
      head_git_exercise.authors.to_a.map { |a| a[:exercism_username] }
    end

    memoize
    def contributor_usernames_config
      head_git_exercise.contributors.to_a.map { |a| a[:exercism_username] }
    end

    memoize
    def exercise_config
      # TODO: determine what to do when the exercise could not be found
      concept_exercises_config.find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
