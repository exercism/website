class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions, :context

  def call
    discussions.
      includes(:solution, :exercise, :track, :student, :mentor).
      map { |d| SerializeMentorDiscussion.(d, context) }
  end
end
