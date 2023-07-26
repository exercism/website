class Git::SyncExerciseContributors < Git::Sync
  include Mandate

  def initialize(exercise)
    super(exercise.track, exercise.synced_to_git_sha)
    @exercise = exercise
  end

  def call
    ActiveRecord::Base.transaction do
      contributors = ::User.with_data.where(data: { github_username: contributors_config })
      contributors.find_each { |contributor| ::Exercise::Contributorship::Create.(exercise, contributor) }

      # This is required to remove contributors that were already added
      exercise.reload.update!(contributors:)

      # TODO: (Optional) consider what to do with missing contributors
      missing_contributors = contributors_config - contributors.map(&:github_username)
      Rails.logger.error "Missing contributors: #{missing_contributors.join(', ')}" if missing_contributors.present?
    end
  end

  private
  attr_reader :exercise

  memoize
  def contributors_config
    head_git_exercise.contributors.to_a
  end

  memoize
  def head_git_exercise
    exercise_config = head_git_track.find_exercise(exercise.uuid)
    Git::Exercise.new(exercise_config[:slug], exercise.git_type, git_repo.head_sha, repo: git_repo)
  end
end
