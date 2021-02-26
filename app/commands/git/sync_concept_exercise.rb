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

      update_authors!
      update_contributors!
    end

    private
    attr_reader :exercise

    def update_authors!
      authors = ::User.where(handle: author_usernames_config)
      authors.find_each { |author| ::Exercise::Authorship::Create.(exercise, author) }

      # This is required to remove authors that were already added
      exercise.update!(authors: authors)

      # TODO: consider what to do with missing authors
      missing_authors = author_usernames_config - authors.map(&:handle)
      Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
    end

    def update_contributors!
      contributors = ::User.where(handle: contributor_usernames_config)
      contributors.find_each { |contributor| ::Exercise::Contributorship::Create.(exercise, contributor) }

      # This is required to remove contributors that were already added
      exercise.update!(contributors: contributors)

      # TODO: consider what to do with missing contributors
      missing_contributors = contributor_usernames_config - contributors.map(&:handle)
      Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
    end

    def exercise_needs_updating?
      exercise_config_modified? || exercise_files_modified?
    end

    def exercise_config_modified?
      return false unless track_config_modified?

      exercise_config[:slug] != exercise.slug ||
        exercise_config[:name] != exercise.title ||
        !!exercise_config[:deprecated] != exercise.deprecated ||
        exercise_config[:concepts].sort != exercise.taught_concepts.map(&:slug).sort ||
        exercise_config[:prerequisites].sort != exercise.prerequisites.map(&:slug).sort
    end

    def exercise_files_modified?
      head_git_exercise.tooling_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_concepts(slugs)
      slugs.map do |slug|
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
