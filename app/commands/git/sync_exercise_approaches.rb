module Git
  class SyncExerciseApproaches < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      sync_approaches!
      sync_introduction_authors!
      sync_introduction_contributors!
      ::Exercise::UpdateHasApproaches.(exercise)
    end

    private
    attr_reader :exercise

    def sync_approaches!(approach_config)
      # TODO: get exercise slug from config
      # git_approach = Git::Exercise::Approach.new(approach_config[:slug], exercise.slug, exercise.git_type, git_repo.head_sha,
      #   repo: git_repo)

      # TODO: update approach
    end

    def sync_authors!(approach, author_github_usernames)
      ActiveRecord::Base.transaction do
        authors = ::User.where(github_username: author_github_usernames)
        authors.find_each { |author| ::Exercise::Approach::Authorship::Create.(exercise, author) }

        # This is required to remove authors that were already added
        approach.reload.update!(authors:)

        # TODO: (Optional) consider what to do with missing authors
        missing_authors = author_github_usernames - authors.pluck(:github_username)
        Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
      end
    end

    def sync_contributors!(approach, contributor_github_usernames)
      ActiveRecord::Base.transaction do
        contributors = ::User.where(github_username: contributor_github_usernames)
        contributors.find_each { |author| ::Exercise::Approach::Contributorship::Create.(exercise, author) }

        # This is required to remove contributors that were already added
        approach.reload.update!(contributors:)

        # TODO: (Optional) consider what to do with missing contributors
        missing_contributors = contributor_github_usernames - contributors.pluck(:github_username)
        Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
      end
    end

    def sync_introduction_authors!
      ActiveRecord::Base.transaction do
        authors = ::User.where(github_username: authors_config)
        authors.find_each { |author| ::Exercise::Approaches::IntroductionAuthorship::Create.(exercise, author) }

        # This is required to remove authors that were already added
        exercise.reload.update!(approach_introduction_authors: authors)

        # TODO: (Optional) consider what to do with missing authors
        missing_authors = authors_config - authors.pluck(:github_username)
        Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
      end
    end

    def sync_introduction_contributors!
      ActiveRecord::Base.transaction do
        contributors = ::User.where(github_username: contributors_config)
        contributors.find_each { |contributor| ::Exercise::Approaches::IntroductionContributorship::Create.(exercise, contributor) }

        # This is required to remove contributors that were already added
        exercise.reload.update!(approach_introduction_contributors: contributors)

        # TODO: (Optional) consider what to do with missing contributors
        missing_contributors = contributors_config - contributors.pluck(:github_username)
        Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
      end
    end

    memoize
    def approaches_config = head_git_approaches.approaches.to_a

    memoize
    def authors_config = head_git_approaches.introduction_authors.to_a

    memoize
    def contributors_config = head_git_approaches.introduction_contributors.to_a

    memoize
    def head_git_approaches = head_git_exercise.approaches

    memoize
    def head_git_exercise
      exercise_config = head_git_track.find_exercise(exercise.uuid)
      Git::Exercise.new(exercise_config[:slug], exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
