module Git
  class SyncConceptExercise < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      return exercise.update!(synced_to_git_sha: head_git_exercise.commit.oid) unless exercise_needs_updating?

      exercise.update!(
        slug: exercise_config[:slug],
        title: exercise_config[:name],
        deprecated: exercise_config[:deprecated] || false,
        git_sha: head_git_exercise.commit.oid,
        synced_to_git_sha: head_git_exercise.commit.oid,
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
      authors.each { |author| ::Exercise::Authorship::Create.(exercise, author) }

      missing_authors = author_usernames_config - authors.map(&:handle)
      Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
    end

    def update_contributors!
      contributors = ::User.where(handle: contributor_usernames_config)
      contributors.each { |contributor| ::Exercise::Contributorship::Create.(exercise, contributor) }

      missing_contributors = contributor_usernames_config - contributors.map(&:handle)
      Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
    end

    def exercise_needs_updating?
      return false if synced_to_head?

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
      head_git_exercise.non_ignored_absolute_filepaths.any? { |filepath| filepath_in_diff?(filepath) }
    end

    def find_concepts(slugs)
      slugs.map do |slug|
        concept_config = concepts_config.find { |e| e[:slug] == slug }
        ::Track::Concept.find_by!(uuid: concept_config[:uuid])
      end
    end

    memoize
    def author_usernames_config
      head_git_exercise.authors.to_a.map { |a| a["exercism_username"] }
    end

    memoize
    def contributor_usernames_config
      head_git_exercise.contributors.to_a.map { |a| a["exercism_username"] }
    end

    memoize
    def exercise_config
      # TODO: determine what to do when the exercise could not be found
      concept_exercises_config.find { |e| e[:uuid] == exercise.uuid }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.track.slug, exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
