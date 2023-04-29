class SerializeMentorDiscussionsForStudent
  include Mandate

  initialize_with :discussions

  def call
    discussions.
      includes(
        :solution, :exercise, :track,
        mentor: { avatar_attachment: :blob },
        student: { avatar_attachment: :blob }
      ).
      map { |d| SerializeMentorDiscussionForStudent.(d) }
  end
end
