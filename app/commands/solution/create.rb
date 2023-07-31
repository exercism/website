class Solution::Create
  include Mandate

  initialize_with :user, :exercise

  def call
    guard!

    begin
      solution_class.create!(user:, exercise:).tap do |solution|
        record_activity!(solution)
        log_metric!(solution)
      end
    rescue ActiveRecord::RecordNotUnique
      solution_class.find_by!(
        user:,
        exercise:
      )
    end
  end

  private
  def guard!
    raise UserTrackNotFoundError if user_track.external?
    raise ExerciseLockedError unless user_track.exercise_unlocked?(exercise)
  end

  def record_activity!(solution)
    User::Activity::Create.(
      :started_exercise,
      user,
      track: exercise.track,
      solution:
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create activity"
    Rails.logger.error e.message
  end

  def solution_class
    case exercise
    when ConceptExercise
      ConceptSolution
    when PracticeExercise
      PracticeSolution
    else
      # Guard against some further third type
      raise RuntimeError
    end
  end

  def log_metric!(solution)
    Metric::Queue.(:start_solution, solution.created_at, solution:, track:, user:)
  end

  memoize
  def user_track = UserTrack.for(user, track)

  memoize
  def track = exercise.track
end
