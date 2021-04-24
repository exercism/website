class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions

  def call
    discussions.includes(:exercise, :track, :student).
      map { |d| SerializeMentorDiscussion.(d) }
  end
end
