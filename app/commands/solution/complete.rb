class Solution::Complete
  include Mandate

  initialize_with :solution, :user_track

  def call
    raise SolutionHasNoIterationsError if solution.iterations.empty?

    solution.with_lock do
      return if solution.completed?

      solution.update!(completed_at: Time.current)
    end

    award_badges!
    award_trophies!
    record_activity!
    log_metric!
    track_exercise_completed!
  end

  private
  def award_badges!
    %i[anybody_there all_your_base whatever lackadaisical].each do |badge|
      AwardBadgeJob.perform_later(user, badge, context: exercise)
    end

    AwardBadgeJob.perform_later(user, :conceptual, context: exercise)
    AwardBadgeJob.perform_later(user, :completer)
  end

  def award_trophies!
    AwardTrophyJob.perform_later(user, track, :completed_all_exercises)
    AwardTrophyJob.perform_later(user, track, :completed_twenty_exercises)
    AwardTrophyJob.perform_later(user, track, :completed_fifty_percent_of_exercises)
    AwardTrophyJob.perform_later(user, track, :completed_learning_mode)
    AwardTrophyJob.perform_later(user, track, :completed_five_hard_exercises, context: exercise)
  end

  def record_activity!
    User::Activity::Create.(
      :completed_exercise,
      user,
      track: exercise.track,
      solution:
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create activity"
    Rails.logger.error e.message
  end

  def log_metric!
    Metric::Queue.(:complete_solution, solution.completed_at, solution:, track:, user:)
  end

  # This is only reached when this call completed the solution, so the
  # event isn't sent again for a solution that was already completed. The
  # job works out the user's activity, which refreshes their person
  # properties and adds exercises_completed (including this one) to the
  # event.
  def track_exercise_completed!
    Analytics::TrackEvent.defer(
      user,
      "exercise_completed",
      properties: {
        track: track.slug,
        exercise: exercise.slug
      },
      set_person_properties: true,
      snapshot_activity: true
    )
  end

  memoize
  def user = solution.user

  memoize
  def exercise = solution.exercise

  memoize
  def track = solution.track
end
