class Solution::Publish
  include Mandate

  initialize_with :solution, :user_track, :iteration_idx

  def call
    Solution::Complete.(solution, user_track) unless solution.completed?

    solution.with_lock do
      return if solution.published?

      ActiveRecord::Base.transaction do
        solution.update(published_at: Time.current)
        Solution::PublishIteration.(solution, iteration_idx)
      end
    end

    award_reputation!
    award_badges!
    record_activity!
    log_metric!
    update_num_published_solutions_on_exercise!
  end

  private
  def award_reputation!
    level = exercise.concept_exercise? ? :concept : exercise.difficulty_category
    User::ReputationToken::Create.defer(
      solution.user,
      :published_solution,
      solution:,
      level:
    )
  end

  def award_badges!
    %i[functional_february mechanical_march analytical_april mind_shifting_may].each do |badge|
      AwardBadgeJob.perform_later(solution.user, badge)
    end
  end

  def record_activity!
    User::Activity::Create.(
      :published_exercise,
      solution.user,
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
    CacheNumPublishedSolutionsOnExerciseJob.perform_later(exercise)
  end

  delegate :exercise, to: :solution
end
