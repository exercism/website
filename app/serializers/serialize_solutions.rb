class SerializeSolutions
  include Mandate

  initialize_with :solutions, :user

  def call
    solutions.includes(:exercise, :track).map do |solution|
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
