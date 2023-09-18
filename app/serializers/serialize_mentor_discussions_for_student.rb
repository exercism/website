class SerializeMentorDiscussionsForStudent
  include Mandate

  initialize_with :discussions

  def call
    discussions.
      includes(
        :solution, :exercise, :track, :mentor, :student
      ).
      map { |d| SerializeMentorDiscussionForStudent.(d) }
  end
end
