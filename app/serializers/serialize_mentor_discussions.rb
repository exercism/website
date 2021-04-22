class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions

  def call
    discussions.includes(:exercise, :track).
      map { |d| SerializeMentorDiscussion.(d) }
  end
end
