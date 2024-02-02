class Solution::Publish
  include Mandate

  initialize_with :solution, :user_track, :iteration_idx

  def call
    Solution::Complete.(solution, user_track) unless solution.completed?

    solution.with_lock do
      return if solution.published?

      ActiveRecord::Base.transaction do
        solution.update(
          published_at: Time.current,
          allow_comments: user.preferences.allow_comments_on_published_solutions
        )
        Solution::PublishIteration.(solution, iteration_idx, invalidate: false)
      end
    end

    award_reputation!
    award_badges!
    record_activity!
    log_metric!
    update_num_published_solutions_on_exercise!
    User::ResetCache.defer(user, :num_published_solutions)
  end

  private
  delegate :user, to: :solution

  def award_reputation!
    level = exercise.concept_exercise? ? :concept : exercise.difficulty_category
    User::ReputationToken::Create.defer(
      user,
      :published_solution,
      solution:,
      level:
    )
  end

  def award_badges!
    BADGES.each { |badge| AwardBadgeJob.perform_later(user, badge) }
  end

  def record_activity!
    User::Activity::Create.(
      :published_exercise,
      user,
      track: solution.track,
      solution:
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create activity"
    Rails.logger.error e.message
  end

  def log_metric!
    Metric::Queue.(:publish_solution, solution.published_at, solution:, track: user_track.track, user: user_track.user)
  end

  def update_num_published_solutions_on_exercise!
    Exercise::CacheNumPublishedSolutions.defer(exercise)
  end

  delegate :exercise, :user, to: :solution

  BADGES = %i[functional_february mechanical_march analytical_april
              mind_shifting_may summer_of_sexps jurassic_july
              apps_august slimline_september object_oriented_october
              nibbly_november december_diversions completed_12_in_23
              polyglot].freeze
  private_constant :BADGES
end
