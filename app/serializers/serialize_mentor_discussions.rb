class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions, :context

  def call
    discussions.
      includes(:exercise, :track, :student).
      map { |d| SerializeMentorDiscussion.(d, context) }
  end
end
