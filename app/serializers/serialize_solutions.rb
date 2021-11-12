class SerializeSolutions
  include Mandate

  NP1_INCLUDES = [:exercise, :track, { user: :avatar_attachment }].freeze

  initialize_with :solutions, :user

  def call
    solutions_with_includes.map do |solution|
      SerializeSolution.(
        solution,
        has_notifications: !!notification_counts_by_exercise_id[solution.exercise_id]&.positive?
      )
    end
  end

  private
  def solutions_with_includes
    # Some upstream callers pass in a manually constructed kaminari array that already
    # includes the exercise and track. For the other callers, we include it here
    return solutions unless ActiveRecord::Relation

    solutions.includes(*NP1_INCLUDES)
  end

  memoize
  def notification_counts_by_exercise_id
    user.notifications.unread.
      where(exercise_id: solutions.map(&:exercise_id)).
      group(:exercise_id).count
  end
end
