class SerializeSolutions
  include Mandate

  initialize_with :solutions, :user

  def call
    # Some upstream callers pass in a manually constructed kaminari array that already
    # includes the exercise and track. For the other callers, we include it here
    solutions_with_includes = solutions.is_a?(ActiveRecord::Relation) ? solutions.includes(:exercise, :track) : solutions

    solutions_with_includes.map do |solution|
      SerializeSolution.(
        solution,
        has_notifications: !!notification_counts_by_exercise_id[solution.exercise_id]&.positive?
      )
    end
  end

  private
  memoize
  def notification_counts_by_exercise_id
    user.notifications.unread.
      where(exercise_id: solutions.map(&:exercise_id)).
      group(:exercise_id).count
  end
end
