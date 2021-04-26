class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions, :user

  def call
    discussions.includes(:exercise, :track, :student).
      map { |d| SerializeMentorDiscussion.(d, user) }
  end
end
