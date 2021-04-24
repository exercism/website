class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions, :context

  def call
    discussions.
      includes(:exercise, :track, :student).
      map { |r| SerializeMentorDiscussion.(r, context) }
  end
end
