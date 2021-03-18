module Git
  class SyncContributors < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      contributors = ::User.where(handle: contributor_usernames_config)
      contributors.find_each { |contributor| ::Exercise::Contributorship::Create.(exercise, contributor) }

      # This is required to remove contributors that were already added
      exercise.update!(contributors: contributors)

      # TODO: consider what to do with missing contributors
      missing_contributors = contributor_usernames_config - contributors.pluck(:handle)
      Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
    end

    private
    attr_reader :exercise

    memoize
    def contributor_usernames_config
      head_git_exercise.contributors.to_a.map { |a| a[:exercism_username] }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
