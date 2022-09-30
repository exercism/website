module Git
  class SyncExerciseApproaches < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      ::Exercise::UpdateHasApproaches.(exercise)

      # TODO: fix
      # sync_introduction_authors!
    end

    private
    attr_reader :exercise

    def sync_introduction_authors!
      ActiveRecord::Base.transaction do
        authors = ::User.where(github_username: authors_config)
        authors.find_each { |author| ::Exercise::Approaches::IntroductionAuthorship::Create.(exercise, author) }

        # This is required to remove authors that were already added
        exercise.reload.update!(approach_introduction_authors:)

        # TODO: (Optional) consider what to do with missing authors
        missing_authors = authors_config - authors.pluck(:github_username)
        Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
      end
    end

    memoize
    def authors_config
      head_git_exercise.approaches_introduction_authors.to_a
    end

    memoize
    def head_git_exercise
      exercise_config = head_git_track.find_exercise(exercise.uuid)
      Git::Exercise.new(exercise_config[:slug], exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
