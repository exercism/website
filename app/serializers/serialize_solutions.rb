class SerializeSolutions
  include Mandate

  NP1_INCLUDES = %i[exercise track user].freeze

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
  memoize
  def solutions_with_includes
    solutions.to_active_relation.includes(*NP1_INCLUDES)
  end

  memoize
  def notification_counts_by_exercise_id
    user.notifications.unread.
      where(exercise_id: solutions_with_includes.map(&:exercise_id)).
      group(:exercise_id).count
  end
end
