class SerializeMentorDiscussionsForStudent
  include Mandate

  initialize_with :discussions

  def call
    discussions.
      includes(:solution, :exercise, :track, :student, :mentor).
      map { |d| SerializeMentorDiscussionForStudent.(d) }
  end
end
